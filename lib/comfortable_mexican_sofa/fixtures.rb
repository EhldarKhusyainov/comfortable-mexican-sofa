module ComfortableMexicanSofa::Fixtures
  
  def self.sync
    
  end
  
  def self.sync_layouts(site, path = nil, root = true, parent = nil, layout_ids = [])
    return unless path ||= find_path(site, 'layouts')
    
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      slug = path.split('/').last
      layout = site.layouts.find_by_slug(slug) || site.layouts.new(:slug => slug)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          attributes = YAML.load_file(file_path).symbolize_keys!
          layout.label = attributes[:label] || slug.titleize
        end
      elsif layout.new_record?
        layout.label = slug.titleize
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, 'content.html'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          layout.content = File.open(file_path, 'rb').read
        end
      end
      if File.exists?(file_path = File.join(path, 'css.css'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          layout.css = File.open(file_path, 'rb').read
        end
      end
      if File.exists?(file_path = File.join(path, 'js.js'))
        if layout.new_record? || File.mtime(file_path) > layout.updated_at
          layout.js = File.open(file_path, 'rb').read
        end
      end
      
      # saving
      layout.parent = parent
      layout.save! if layout.changed?
      layout_ids << layout.id
      
      # checking for nested fixtures
      layout_ids += sync_layouts(site, path, false, layout, layout_ids)
    end
    
    # removing all db entries that are not in fixtures
    Cms::Layout.where('id NOT IN (?)', layout_ids).each{ |s| s.destroy } if root
    
    # returning ids of layouts in fixtures
    layout_ids
  end
  
  def self.sync_pages
    # TODO
  end
  
  def self.sync_snippets(site)
    return unless path = find_path(site, 'snippets')
    
    snippet_ids = []
    Dir.glob("#{path}/*").select{|f| File.directory?(f)}.each do |path|
      slug = path.split('/').last
      snippet = site.snippets.find_by_slug(slug) || site.snippets.new(:slug => slug)
      
      # updating attributes
      if File.exists?(file_path = File.join(path, "_#{slug}.yml"))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at
          attributes = YAML.load_file(file_path).symbolize_keys!
          snippet.label = attributes[:label] || slug.titleize
        end
      elsif snippet.new_record?
        snippet.label = slug.titleize
      end
      
      # updating content
      if File.exists?(file_path = File.join(path, 'content.html'))
        if snippet.new_record? || File.mtime(file_path) > snippet.updated_at
          snippet.content = File.open(file_path, 'rb').read
        end
      end
      
      # saving
      snippet.save! if snippet.changed?
      snippet_ids << snippet.id
    end
    
    # removing all db entries that are not in fixtures
    Cms::Snippet.where('id NOT IN (?)', snippet_ids).each{ |s| s.destroy }
  end
  
  def self.find_path(site, dir)
    path = nil
    File.exists?(path = File.join(ComfortableMexicanSofa.config.fixtures_path, site.hostname, dir)) ||
    !ComfortableMexicanSofa.config.enable_multiple_sites &&
    File.exists?(path = File.join(ComfortableMexicanSofa.config.fixtures_path, dir))
    return path
  end
  
end