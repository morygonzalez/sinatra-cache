# Sinatra::Cache

A Sinatra Extension that makes Page and Fragment Caching easy.

## IMPORTANT INFORMATION

<b>This is a completely rewritten extension that basically breaks all previous versions of it.</b>

So use with care!  You have been warned ;-)

----

With that said, on to the real stuff.

## Installation

```sh
#  Add RubyGems.org (former Gemcutter) to your RubyGems sources
$  gem sources -a http://rubygems.org

$  (sudo)? gem install sinatra-cache
```

## Dependencies

This Gem depends upon the following:

### Runtime:

* sinatra ( >= 1.0.a )

Optionals:

* sinatra-settings[http://github.com/kematzy/sinatra-settings] (>= 0.1.1) # to view default settings in a browser display.

### Development & Tests:

* sinatra-tests (>= 0.1.6)
* rspec (>= 1.3.0 )
* rack-test (>= 0.5.3)
* rspec_hpricot_matchers (>= 0.1.0)
* fileutils
* sass
* ostruct
* yaml
* json

## Getting Started

To start caching your app's ouput, just require and register
the extension in your sub-classed Sinatra app:

```ruby
require 'sinatra/cache'

class YourApp < Sinatra::Base

  # NB! you need to set the root of the app first
  set :root, '/path/2/the/root/of/your/app'

  register(Sinatra::Cache)

  set :cache_enabled, true  # turn it on

  <snip...>

end
```

In your "classic" Sinatra app, you just require the extension and set some key settings, like this:

```ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/cache'

# NB! you need to set the root of the app first
set :root, '/path/2/the/root/of/your/app'
set :public, '/path/2/public'

set :cache_enabled, true  # turn it on

<snip...>
```

That's more or less it.

You should now be caching your output by default, in <tt>:production</tt> mode, as long as you use
one of Sinatra's render methods:

    erb(),  erubis(), haml(), sass(), builder(), etc..

...or any render method that uses <tt>Sinatra::Templates#render()</tt> as its base.

## Configuration Settings

The default settings should help you get moving quickly, and are fairly common sense based.

#### <tt>:cache_enabled</tt>

This setting toggles the cache functionality On / Off.
Default is: <tt>false</tt>

#### <tt>:cache_environment</tt>

Sets the environment during which the cache functionality is active.
Default is: <tt>:production</tt>

#### <tt>:cache_page_extension</tt>

Sets the default file extension for cached files.
Default is: <tt>.html</tt>

#### <tt>:cache_output_dir</tt>

Sets cache directory where the cached files are stored.
Default is:  == "/path/2/your/app/public"

Although you can set it to the more ideal '<tt>..public/system/cache/</tt>'
if you can get that to work with your webserver setup.

#### <tt>:cache_fragments_output_dir</tt>

Sets the directory where cached fragments are stored.
Default is the '../tmp/cache_fragments/' directory at the root of your app.

This is for security reasons since you don't really want your cached fragments publically available.

#### <tt>:cache_fragments_wrap_with_html_comments</tt>

This setting toggles the wrapping of cached fragments in HTML comments. (see below)
Default is: <tt>true</tt>

#### <tt>:cache_logging</tt>

This setting toggles the logging of various cache calls. If the app has access to the <tt>#logger</tt> method,
curtesy of Sinatra::Logger[http://github.com/kematzy/sinatra-logger] then it will log there, otherwise logging
is silent.

Default is: <tt>true</tt>

#### <tt>:cache_logging_level</tt>

Sets the level at which the cache logger should log it's messages.
Default is: <tt>:info</tt>

Available options are: [:fatal, :error, :warn, :info, :debug]

## Basic Page Caching

By default caching only happens in <tt>:production</tt> mode, and via the Sinatra render methods, erb(), etc,

So asuming we have the following setup (continued from above)

```ruby
class YourApp

  <snip...>

  set :cache_output_dir, "/full/path/2/app/root/public/system/cache"

  <snip...>

  get('/') { erb(:index) }            # => cached as '../index.html'

  get('/contact') { erb(:contact) }   # => cached as '../contact.html'

  # NB! the trailing slash on the URL
  get('/about/') { erb(:about) }      # => cached as '../about/index.html'

  get('/feed.rss') { builder(:feed) }  # => cached as '../feed.rss'
  # NB! uses the extension of the passed URL,
  # but DOES NOT ensure the format of the content based on the extension provided.

  # complex URL with multiple possible params
  get %r{/articles/?([\s\w-]+)?/?([\w-]+)?/?([\w-]+)?/?([\w-]+)?/?([\w-]+)?/?([\w-]+)?}  do
    erb(:articles)
  end
  # with the '/articles/a/b/c  => cached as ../articles/a/b/c.html

  # NB! the trailing slash on the URL
  # with the '/articles/a/b/c/  => cached as ../articles/a/b/c/index.html

  # CSS caching via Sass  # => cached as '.../css/screen.css'
  get '/css/screen.css' do
    content_type 'text/css'
    sass(:'css/screen')
  end

  # to turn off caching on certain pages.
  get('/dont/cache/this/page') { erb(:aview, :cache => false) }   # => is NOT cached

  # NB! any query string params - [ /?page=X&id=y ] - are stripped off and TOTALLY IGNORED
  # during the caching process.

end
```

OK, that's about all you need to know about basic Page Caching right there. Read the above example
carefully until you understand all the variations.

## Fragment Caching

If you just need to cache a fragment of a page, then you'd do as follows:

```ruby
class YourApp

  set :cache_fragments_output_dir, "/full/path/2/fragments/store/location"

end
```

Then in your views / layouts add the following:

```erb
<% cache_fragment(:name_of_fragment) do %>
  # do something worth caching
<% end %>
```

Each fragment is stored in the same directory structure as your request
so, if you have a request like this:

  get '/articles/2010/02' ...

...the cached fragment will be stored as:

    ../tmp/cache_fragments/articles/2010/02/< name_of_fragment >.html

This enables you to use similar names for your fragments or have
multiple URLs use the same view / layout.

### An important limitation

The fragment caching is dependent upon the final URL, so in the case of
a blog, where each article uses the same view, but through different URLs,
each of the articles would cache it's own fragment, which is ineffecient.

To sort-of deal with this limitation I have temporarily added a very hackish
'fix' through adding a otion parameter (see example below), which will store
fragment cache to the location below.

    ../tmp/cache_fragments/shared/

So given the URL:

    get '/articles/2010/02/fragment-caching-with-sinatra-cache' ...

and the following <tt>#cache_fragment</tt> declaration in your view

```erb
<% cache_fragment(:name_of_fragment, shared:, true) do %>
  # do something worth caching
<% end %>
```

...the cached fragment would be stored as:

    ../tmp/cache_fragments/shared/< name_of_fragment >.html

Any other URLs with would use the same cached fragment.

## Cache Expiration

When you pass `:expires_in` option, you can set cache expiration time.

```erb
<% cache_fragment :name_of_fragment, expires_in: 300 do %>
  # do something worth caching
<% end %>
```

If you don't set any, default expiration time is 900 seconds (15 minutes).

<b>Under development, and not entirely final.</b> See Todo's below for more info.

To expire a cached item - file or fragment you use the :cache_expire() method.

```ruby
cache_expire('/contact')  =>  expires ../contact.html

# NB! notice the trailing slash
cache_expire('/contact/')  =>  expires ../contact/index.html

cache_expire('/feed.rss')  =>  expires ../feed.rss
```

To expire a cached fragment:

```ruby
cache_expire('/some/path', :fragment => :name_of_fragment )

  =>  expires ../some/path/:name_of_fragment.html
```

## A few important points to consider

### The DANGERS of URL query string params

By default the caching ignores the query string params, but that's not the only problem with query params.

Let's say you have a URL like this:

    /products/?product_id=111

and then inside that template [ .../views/products.erb ], you use the <tt>params[:product_id]</tt>
param passed in for some purpose.

```erb
<ul>
  <li>Product ID: <%= params[:product_id] %></li>  # => 111
  ...
</ul>
```

If you cache this URL, then the cached file [ ../cache/products.html ] will be stored with that
value embedded. Obviously not ideal for any other similar URLs with different <tt>product_id</tt>'s

To overcome this issue, use either of these two methods.

```ruby
# in your_app.rb

# turning off caching on this page

  get '/products/' do
    ...
    erb(:products, :cache => false)
  end

# or

# rework the URLs to something like '/products/111 '

get '/products/:product_id' do
  ...
  erb(:products)
end
```

Thats's about all the information you need to know.

## RTFM

If the above is not clear enough, please check the Specs for a better understanding.

## Errors / Bugs

If something is not behaving intuitively, it is a bug, and should be reported.
Report it here: http://github.com/kematzy/sinatra-cache/issues

## TODOs

* Improve the fragment caching functionality

  * Decide on how to handle site-wide shared fragments.

  * Make the shared fragments more dynamic or usable

* Work out how to use the <tt>cache_expire()</tt> functionality in a logical way.

* Work out and include instructions on how to use a '../public/custom/cache/dir' with Passenger.

* Enable time-based / date-based cache expiry and regeneration of the cached-pages. [ht oakleafs]

* Enable .gz version of the cached file, further reducing the processing on the server. [ht oakleafs]
  It would be killer to have <b>an extra .gz file next to the cached file</b>. That way, in Apache, you set it up like that:

```apache
    RewriteCond %{HTTP:Accept-Encoding} gzip
    RewriteCond %{REQUEST_FILENAME}.gz$ -f
    RewriteRule ^(.*)$ $1.gz [L,QSA]
```

  And it should serve the compressed file if available.

* Write more tests to ensure everything is very solid.

* Any other improvements you or I can think of.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  * (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2009-2010 kematzy. Released under the MIT License.

See LICENSE for details.

### Credits

A big <b>Thank You!</b> goes to rtomayko[http://github/rtomayko], blakemizerany[http://github.com/blakemizerany/]
and others working on the Sinatra framework.

### Inspirations

Inspired by code from Rails[http://rubyonrails.com/] & Merb[http://merbivore.com/]
and other sources
