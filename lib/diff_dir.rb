require 'find'
require 'digest/md5'
require 'pry-debugger'

module DiffDir
  class Directory
    attr_reader :name, :files

    def initialize(dirname = '.')
      @name = dirname
      @files = []
      # binding.pry
      Find.find(dirname) do |f|
        lstat = File.lstat f
        if lstat.directory?
          Find.prune if lstat.symlink? or f[-4,4] == '.svn'
        else
          f[0..dirname.length] = ''
          @files.push f
        end
      end
    end

    def - (other)
      @files - other.files
    end

    def & (other)
      @files & other.files
    end
  end

  class << self

    def md5sum(f)
      md5 = Digest::MD5.new
      while mb = f.read(1024 * 1024)
        md5.update(mb)
      end
      md5.hexdigest
    end

    def md5cmp(fileA, fileB)
      md5hexA = md5hexB = nil
      File.open(fileA) do |f|
        md5hexA = md5sum(f)
      end
      File.open(fileB) do |f|
        md5hexB = md5sum(f)
      end

      md5hexA == md5hexB
    end

    def filecmp(fileA, fileB)
      linesA = File.readlines(fileA)
      linesB = File.readlines(fileB)
      diff = (linesA - linesB)
      diff = (linesB - linesA) if diff == []

      unless diff.empty?
        diff.each do |line|
          if line =~ /^@version/ then diff.delete(line) end
        end
      end

      diff
    end

    def listup(arr)
      arr.sort.each do |f|
        puts f
      end
      puts
    end

    def listup_diff(arr, dirA, dirB)
      arr.sort.each do |f|
        stA = File.stat(dirA + '/' + f)
        stB = File.stat(dirB + '/' + f)
        puts "#{f}\t#{dirA}:#{stA.size} #{stA.mtime} \t#{dirB}:#{stB.size} #{stB.mtime}"
      end
      puts
    end

    def usage
      STDERR.print <<EOF
    usage #{ File.basename $0 } [-dosi] dirA dirB
        -d no print diff
        -o no print only
        -s no print same
        -i no print into diff
EOF
      exit 1
    end

    def argck_isdir(name)
      unless File.directory?(name) do
          STDERR.print "#{name}: not a directory !\n"
          usage
        end
      end
    end

    # def is_samefile_md5?(parent_dirA, parent_dirB, file)
    #   fileA = parent_dirA.name + '/' + file
    #   fileB = parent_dirB.name + '/' + file

    #   File.size(fileA) == File.size(fileB) && md5cmp(fileA, fileB)
    # end

    def is_samefile?(parent_dirA, parent_dirB, file)
      fileA = parent_dirA.name + '/' + file
      fileB = parent_dirB.name + '/' + file

      filecmp(fileA, fileB) == []
    end


    def only_files(dirA, dirB)
      dirA - dirB
    end

    def diff_files(dirA, dirB)
      # binding.pry
      diff = []
      (dirA & dirB).each do |f|
        diff << f unless is_samefile?(dirA, dirB, f)
      end
      diff
    end

    def same_files(dirA, dirB)
      same = []
      (dirA & dirB).each do |f|
        same << f if is_samefile?(dirA, dirB, f)
      end
      same
    end
  end

end

# run when program_name was called
if __FILE__ == $PROGRAM_NAME

  opt_only = opt_same = opt_diff = opt_info = true

  while ARGV[0] =~ /^-/
    arg = ARGV.shift
    opt_diff = false if arg =~ /d/
    opt_only = false if arg =~ /o/
    opt_same = false if arg =~ /s/
    opt_info = false if arg =~ /i/
    usage if arg =~ /[^-dosi]/
  end


  DiffDir.usage if ARGV.size != 2
  DiffDir.argck_isdir(ARGV[0])
  DiffDir.argck_isdir(ARGV[1])

  dirA = DiffDir::Directory.new(ARGV.shift)
  dirB = DiffDir::Directory.new(ARGV.shift)

  if opt_only
    puts "#{dirA.name} only:"
    DiffDir.listup(DiffDir.only_files(dirA, dirB))

    puts "#{dirB.name} only:"
    DiffDir.listup(DiffDir.only_files(dirB, dirA))
  end

  if opt_same or opt_diff
    if opt_diff
      puts 'diff:'
      if opt_info
        DiffDir.listup_diff(DiffDir.diff_files(dirA, dirB), dirA.name, dirB.name)
      else
        DiffDir.listup(DiffDir.diff_files(dirA, dirB))
      end
    end
  end

  if opt_same
    puts 'same:'
    DiffDir.listup(DiffDir.same_files(dirA, dirB))
  end
end
