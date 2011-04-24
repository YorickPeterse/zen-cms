require __DIR__('comments/model/comment.rb')
require __DIR__('comments/controller/comments')
require __DIR__('comments/controller/comments_form')
require __DIR__('comments/plugin/comments')

Zen::Language.options.paths.push(__DIR__('comments'))
Zen::Language.load('comments')

Zen::Package.add do |p|
  p.name          = 'comments'
  p.author        = 'Yorick Peterse'
  p.url           = 'http://yorickpeterse.com/'
  p.about         = "Allow users to post comments on any given section entry (as long as 
the section allows it)."

  p.directory     = __DIR__('comments')
  p.migration_dir = __DIR__('../migrations')
  
  p.menu = [{
    :title => lang('comments.titles.index'),
    :url   => "admin/comments"
  }]

  p.controllers = {
    lang('comments.titles.index') => Comments::Controller::Comments
  }
end

Zen::Plugin.add do |p|
  p.name    = 'comments'
  p.author  = 'Yorick Peterse'
  p.url     = 'http://yorickpeterse.com/'
  p.about   = 'Plugin that can be used to retrieve comments.'
  p.plugin  = Comments::Plugin::Comments
end
