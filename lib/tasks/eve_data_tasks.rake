# vim: set foldmethod=marker smarttab sw=2: #

require 'eve_data/version'
require 'tempfile'
require 'open-uri'
require 'uri'
require 'digest/md5'
require 'fileutils'
require 'ruby-progressbar'

namespace :eve_data do
  desc "Download EDD to data/#{EveData::DATAFILE}"
  task :download do # {{{
    data_dir = Rails.root.join('data')
    file_complete = data_dir.join(EveData::DATAFILE)
#    md5_complete = "#{file_complete}.md5"

    if File.readable?(file_complete) then
      puts "#{file_complete} already exists"
    else
      uri = EveData::DATAURL
      puts "trying to download #{uri.to_s} to #{file_complete}"
      ret = download_file(uri, file_complete, true)
      puts (ret ? "success." : "failed.")
    end

  end # }}}

  desc "Import Eve Online Static Data Dump to EDD database"
  task :import => :environment do # {{{

#    if ActiveRecord::Base.connection.table_exists? "invTypes"
    if InvTypes.connection.table_exists? "invTypes"
      puts "****************************************************************************"
      puts "you already seem to have imported the database dump (invTypes table exists)."
      puts "if you really want to import again, manually delete the database '#{}'"
      puts "****************************************************************************"
      return false
    end

    file_complete = Rails.root.join('data', EveData::DATAFILE)
    unless File.readable?(file_complete) then
      puts "data dump could not be found in #{file_complete}, trying to download"
      Rake::Task["eve_data:download"].invoke
    end

    unless cfg = ActiveRecord::Base.configurations['eve_data'] then
      raise IOError, "missing 'eve_data' block in config/database.yml"
    end

    Tempfile.open('edd_mysql_import.', Rails.root.join('tmp')) do |f|
      f.printf("[client]\n")
      f.printf("host=%s\n", cfg["host"]) if cfg["host"]
      f.printf("socket=%s\n", cfg["socket"]) if cfg["socket"]
      f.printf("port=%s\n", cfg["port"]) if cfg["port"]
      f.printf("user=%s\n", cfg["username"]) if cfg["username"]
      f.printf("password=%s\n", cfg["password"]) if cfg["password"]
      f.flush

      puts "trying to connect to mysql server:"
      ret = system("mysqladmin --defaults-extra-file=#{f.path} status")
      unless ret then
        raise IOError, "unable to connect to mysql server (mysqladmin status failed; maybe incorrect pw?"
        return false
      end

      puts "now trying to import dump from '#{file_complete}':"
      ret = system("bzcat #{file_complete} | mysql --defaults-extra-file=#{f.path} #{cfg["database"]}")
      puts (ret ? "success!" : "failed!")
    end

    true
  end # }}}
end

def download_file(uri, fname, use_pbar = false) # {{{
  dname = File.dirname(fname)

  pbar = nil
  FileUtils.mkdir_p(dname) unless Dir.exists?(dname)
  open(fname, "wb") do |outf|
    open(uri, 
      :content_length_proc => lambda { |t|
        if t && 0 < t and use_pbar
          pbar = ProgressBar.create(:title => fname, :total => t, :format => '%a %e |%b>>%i| %p%%')
        end
      },
      :progress_proc => lambda { |s|
        pbar.progress = s if pbar
      }) do |f|

      outf.write f.read
    end
    pbar.finish if pbar
  end

  system(EveData::FILE_CHECK + " " + fname.to_s + " >/dev/null 2>&1")
  ($?.exitstatus > 0) ? false : true
end # }}}

