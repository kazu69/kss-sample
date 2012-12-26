require 'sinatra'
require 'sinatra/capture'
require 'erb'
require 'sass'
require 'kss'
 
set :partial_template_engine, :erb
set :scss, :style => :compact
 
 # sassファイルを格納するディレクリをsassに変更した
set :views,   File.dirname(__FILE__)    + '/views/sass'

# kssでパーするファイルの格納ディレクトリ
before do
    @styleguide = Kss::Parser.new('views/sass')
end

helpers do
 
  # kssでパースするスタイルシートをまとめて出力
  def stylesheets
    stylesheets = ''
    @styleguide.sections.each do |key, val|
      filename = val.filename.split(/.scss/).first
      stylesheets += '<link rel="stylesheet" href="stylesheets/' + filename + '.css" type="text/css" />'
    end
    stylesheets
  end
   
  # セクション毎のサンプルを出力
  def styleguide_block(section, &block)
    @section = @styleguide.section(section)
    @sample_html = capture{block.call}
    @row_html = ERB::Util.html_escape @sample_html
    @_out_buf << erb(:_styleguide_partial)
  end
 
end
 
get '/stylesheets/*.css' do
  content_type 'text/css', :charset => 'utf-8'
  filename = params[:splat].first
  scss filename.to_sym
end

get '/' do
  erb :index
end

get '/:section' do
  # Routing
  case params[:section].to_i
  when 1.0
    erb :button
  end
end
 
__END__
 
@@ layout
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="content-type" content="text/html;charset=UTF-8" />
  <title>Styleguide Example</title>
  <link rel="stylesheet" href="stylesheets/layout.css" type="text/css" />
  <%= stylesheets %>
</head>
<body>
  <header>
    Styleguide
  </header>
  <div id="wrapper">
    <nav role="main">
       <ul>
        <li><a href="/">Styleguide</a></li>
        <li><a href="/1.0">1.0 Buttons</a></li>
      </ul>
    </nav>
    <%= yield %>
  </div>
  <script src="javascripts/kss.js"></script>
</body>
</html>
 
@@ index
  <p>各セクションにスタイルガイドブロックを配置することでスタイルガイド生成できます。</p>

@@ button
  <% styleguide_block '1.1' do %>
    <button class="button $modifier">Button</button> 
    <a href="#" class="button $modifier"><span>Button</span></a>
  <% end %>

  <% styleguide_block '1.2' do %>
    <button class="small $modifier">Small</button> 
    <a href="#" class="small $modifier"><span>Small</span></a>
  <% end %>
 
@@ _styleguide_partial
<div class="styleguide-example">
  <h3><%= @section.section %> <em><%= @section.filename %></em></h3>
  <div class="styleguide-description">
    <p><%= @section.description %></p>
    <% if @section.modifiers.any? %>
      <ul class="styleguide-modifier">
        <% @section.modifiers.each do |modifier| %>
          <li><strong><%= modifier.name %></strong> - <%= modifier.description %></li>
        <% end %>
      </ul>
    <% end %>
  </div>
  <div class="styleguide-element">
    <%= @sample_html %>
  </div>
  <% @section.modifiers.each do |modifier| %>
    <div class="styleguide-element styleguide-modifier">
      <span class="styleguide-modifier-name"><%= modifier.name %></span>
      <%# $modifier を modifier に置換 %>
      <%= @sample_html.gsub('$modifier', "#{modifier.class_name}") %>
    </div>
  <% end %>
  <pre class="styleguide-code"><%= @row_html %></pre>
</div>