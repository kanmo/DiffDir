
def multi_mkdir(mpath, mask=0777 ^ File.umask)
  path = ''
  mpath.split('/').each do |f|
    path.concat(f)
    Dir.mkdir(path, mask) unless path == '' || File.exist?(path)
    path.concat('/')
  end
end

def mkfile(name, data)
  File.open(name, 'w') do |f|
    f.puts data
  end
end

def mk_samefile
  mkfile('a/s1', 'b1')
  mkfile('b/s1', 'b1')
  mkfile('a/a1/s1', 'b1')
  mkfile('b/a1/s1', 'b1')
  mkfile('a/a1/a2/a3/s1', 'b1')
  mkfile('b/a1/a2/a3/s1', 'b1')
end

def mk_difffile
  mkfile('a/d1', 'b1')
  mkfile('b/d1', 'd1')
  mkfile('a/a1/d1', 'b1')
  mkfile('b/a1/d1', 'd1')
  mkfile('a/a1/a2/d1', 'b1')
  mkfile('b/a1/a2/d1', 'd1')
  mkfile('a/a1/a2/a3/d1', 'b1')
  mkfile('b/a1/a2/a3/d1', 'd1')
end

def mk_onlyfile
  mkfile('a/o1', 'b1')
  mkfile('b/o2', 'd2')
  mkfile('a/a1/o1', 'b1')
  mkfile('b/a1/o2', 'd1')
  mkfile('a/a1/a2/o1', 'b1')
  mkfile('b/a1/a2/o2', 'd2')
end
