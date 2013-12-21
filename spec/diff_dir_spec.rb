# -*- coding: utf-8 -*-

require 'fileutils'
require_relative '../lib/diff_dir.rb'
require_relative 'spec_helper.rb'

describe DiffDir::Directory do
  before do
    multi_mkdir('a/a1/a2/a3')
    multi_mkdir('b/a1/a2/a3')
  end

  describe '.diff_files' do
    context 'ディレクトリのファイルが同じ場合' do
      before do
        mk_samefile
        @dirA = DiffDir::Directory.new("./a")
        @dirB = DiffDir::Directory.new("./b")
      end

      subject { DiffDir.diff_files(@dirA, @dirB) }
      it { should eq [] }
    end

    context 'ディレクトリのファイルが異なる場合' do
      before do
        mk_difffile
        @dirA = DiffDir::Directory.new("./a")
        @dirB = DiffDir::Directory.new("./b")
      end

      subject { DiffDir.diff_files(@dirA, @dirB) }
      it { should eq ["a1/a2/a3/d1", "a1/a2/d1", "a1/d1", "d1"] }
    end
  end

  describe '.same_files' do
    context 'ディレクトリのファイルが同じ場合' do
      before do
        mk_samefile
        @dirA = DiffDir::Directory.new("./a")
        @dirB = DiffDir::Directory.new("./b")
      end

      subject { DiffDir.same_files(@dirA, @dirB) }
      it { should eq ["a1/a2/a3/s1", "a1/s1", "s1"] }
    end

    context 'ディレクトリのファイルが異なる場合' do
      before do
        mk_difffile
        @dirA = DiffDir::Directory.new("./a")
        @dirB = DiffDir::Directory.new("./b")
      end

      subject { DiffDir.same_files(@dirA, @dirB) }
      it { should eq [] }
    end
  end

  describe '.only_files' do
    context 'ディレクトリのファイルが同じ場合' do
      before do
        mk_samefile
        @dirA = DiffDir::Directory.new("./a")
        @dirB = DiffDir::Directory.new("./b")
      end

      subject { DiffDir.only_files(@dirA, @dirB) }
      it { should eq [] }
    end

    context 'ディレクトリのファイルが異なる場合' do
      before do
        mk_onlyfile
        @dirA = DiffDir::Directory.new("./a")
        @dirB = DiffDir::Directory.new("./b")
      end

      subject { DiffDir.only_files(@dirA, @dirB) }
      it { should eq ["a1/a2/o1", "a1/o1", "o1"] }
    end
  end

  describe '.filecmp' do
    context 'ファイルの中身が同じ場合' do
      before do
        mkfile("a/f1", "test\ntest\n")
        mkfile("a/f2", "test\ntest\n")
      end
      subject { DiffDir.filecmp("a/f1", "a/f2") }
      it { should eq [] }
    end

    context 'ファイルの中身に両方異なる行がある場合' do
      before do
        mkfile("a/f1", "test\ngit\n")
        mkfile("a/f2", "test\nsubversion\n")
      end
      subject { DiffDir.filecmp("a/f1", "a/f2") }
      it { should eq ["git\n", "subversion\n"] }
    end

    context 'ファイルの中身の片方に異なる行がある場合' do
      before do
        mkfile("a/f1", "test\n")
        mkfile("a/f2", "test\nsubversion\n")
      end
      subject { DiffDir.filecmp("a/f1", "a/f2") }
      it { should eq ["subversion\n"] }
    end

    context 'ファイルの中身の片方の異なる行が@versionで始まる場合' do
      before do
        mkfile("a/f1", "test\nsubversion\n@version=1.1.0\n")
        mkfile("a/f2", "test\nsubversion\n")
      end
      subject { DiffDir.filecmp("a/f1", "a/f2") }
      it { should eq [] }
    end

    context 'ファイルの中身の片方の異なる行に@versionが含まれる場合' do
      before do
        mkfile("a/f1", "test\nsubversion\ntest:@version=1.1.0\n")
        mkfile("a/f2", "test\nsubversion\n")
      end
      subject { DiffDir.filecmp("a/f1", "a/f2") }
      it { should eq [] }
    end

  end

  after do
    FileUtils.rm_r(["a", "b"])
  end

end




