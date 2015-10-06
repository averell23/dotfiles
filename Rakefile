require 'rake'

desc "Hook our dotfiles into system-standard positions."
task :install do
  system('ln -s $HOME/Dropbox/misc/private $PWD/private')
  linkables = Dir.glob('{**,private/**}/**.symlink', File::FNM_DOTMATCH)

  skip_all = ENV['SKIP_ALL'] == 'yes'
  overwrite_all = ENV['OVERWRITE_ALL'] == 'yes'
  backup_all = ENV['BACKUP_ALL'] == 'yes'
  is_darwin = `uname -s`.strip == 'Darwin' 

  unless is_darwin && system('which realpath > /dev/null') # check realpath install
    puts "Installing realpath tool"
    if system("gcc -Wall realpath.c -o realpath -framework CoreServices") && system('sudo cp realpath /usr/local/bin')
      puts "Installed realpath tool"
    else
      puts "Could not build the realpath tool"
    end
  end

  # Move the zshenv, so that vim will correctly find rvm ruby... d'oh
  # see https://github.com/tpope/vim-rvm
  if is_darwin && File.exists?('/etc/zshenv')
    puts "Moving zshrc on this Mac"
    system 'sudo mv /etc/zshenv /etc/zshrc'
  end

  linkables.each do |linkable|
    overwrite = false
    backup = false

    file = linkable.split('/', 2).last.split('.symlink').last
    target = "#{ENV["HOME"]}/.#{file}".gsub(/\A\/?private\/?/, '')

    if File.exists?(target) || File.symlink?(target)
      unless skip_all || overwrite_all || backup_all
        puts "File already exists: #{target}, what do you want to do? [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all"
        case STDIN.gets.chomp
        when 'o' then overwrite = true
        when 'b' then backup = true
        when 'O' then overwrite_all = true
        when 'B' then backup_all = true
        when 'S' then skip_all = true
        when 's' then next
        end
      end
      FileUtils.rm_rf(target) if overwrite || overwrite_all
      `mv "$HOME/.#{file}" "$HOME/.#{file}.backup"` if backup || backup_all
    end
    `ln -s "$PWD/#{linkable}" "#{target}"`
  end
end

task :uninstall do

  Dir.glob('**/*.symlink').each do |linkable|

    file = linkable.split('/').last.split('.symlink').last
    target = "#{ENV["HOME"]}/.#{file}"

    # Remove all symlinks created during installation
    if File.symlink?(target)
      FileUtils.rm(target)
    end
    
    # Replace any backups made during installation
    if File.exists?("#{ENV["HOME"]}/.#{file}.backup")
      `mv "$HOME/.#{file}.backup" "$HOME/.#{file}"` 
    end
  
    # Move the zshenv back, see above
    if `uname -s`.strip == 'Darwin' && File.exists?('/etc/zshrc')
      system 'sudo mv /etc/zshrc /etc/zshenv'
    end

  end
end

task :default => 'install'
