require "abstract_feature_branch/engine"

module AbstractFeatureBranch::FileBeautifier
  def self.process(file_path=nil)
    if file_path.nil?
      feature_directory_path = File.join(AbstractFeatureBranch.application_root, 'config', 'features')
      feature_file_path = File.join(AbstractFeatureBranch.application_root, 'config', 'features.yml')
      local_feature_file_path = File.join(AbstractFeatureBranch.application_root, 'config', 'features.local.yml')
      process_directory(feature_directory_path)
      process_file(feature_file_path)
      process_file(local_feature_file_path)
    else
      if File.directory?(file_path)
        process_directory(file_path)
      else
        process_file(file_path)
      end
    end
    AbstractFeatureBranch.logger.info "File beautification done."
  end

  def self.process_directory(directory_path)
    Dir.glob(File.join(directory_path, '**', '*.yml')).each do |file_path|
      process_file(file_path)
    end
  end

  def self.process_file(file_path)
    AbstractFeatureBranch.logger.info "Beautifying #{file_path}..."
    file_content = nil
    File.open(file_path, 'r') do |file|
      file_content = file.readlines.join
    end
    beautified_file_content = beautify(file_content)
    File.open(file_path, 'w+') do |file|
      file << beautified_file_content
    end
  end

  def self.beautify(content)
    #Not relying on ordered hashes for backwards compatibility with Ruby 1.8.7
    sections = []
    section_features = []
    content.split("\n").each do |line|
      if line.strip.empty? || (line.strip.start_with?('#') && !section_features.flatten.empty?)
        # ignore empty line
      elsif line.start_with?(" ")
        section_features.last << line
      else
        sections << line
        section_features << []
      end
    end
    beautified_file_content = ''
    sections.each_with_index do |section, i|
      if section.start_with?('#')
        beautified_file_content << "#{section}\n"
      else
        beautified_file_content << "#{section}\n"
        beautified_file_content << "#{section_features[i].sort.join("\n")}\n\n"
      end
    end
    beautified_file_content
  end
end
