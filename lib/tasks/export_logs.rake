namespace :redshift do
  desc "Exports events from local DB to Redshift through S3 and CSV files"
  task export: :environment do

    # Parse input arguments and initialize variables
    ARGV.each { |a| task a.to_sym do ; end }
    start_index = ARGV[3].to_i
    end_index = ARGV[2].to_i.zero? ? Transaction.count : ARGV[3].to_i
    batch_size = ARGV[3].to_i.zero? ? 10000 : ARGV[3].to_i
    size = end_index - start_index
    num_batches = (size.to_f / batch_size.to_f).ceil
    remainder = size - ((size / batch_size) * batch_size)
    bucket = Aws::S3::Resource.new.bucket(Rails.application.secrets.s3_bucket_name)
    manifest = {entries: []}
    ids = []

    puts "Creating CSV files and uploading"
    Transaction.find_in_batches(start: start_index, batch_size: batch_size).with_index  do |events, batch|
      batch += 1
      break if batch > num_batches

      progressbar = ProgressBar.create(title: "File #{batch} of #{num_batches}", starting_at: 0, total: events.size)

      # If the batches do not divide evenly, the last batch should only contain the remainder number of elements
      events = events.slice(0..remainder - 1) if !remainder.zero? and batch.eql? num_batches

      # create csv file from models and uploads the event csv file to s3


      # Add objects to arrays to process them all later alltogether
      ids += events.map(&:id)
      manifest[:entries] << {url: "s3://#{bucket.name}/#{filename}", mandatory: true}

      # clean up
      File.delete(file.path)
      progressbar.finish
    end
    puts "Finished creating CSVs"

    puts "Deleting events in redshift that will be overwritten..."
    ActiveRecord::Base.establish_connection(:redshift)
    Transaction.where(id: ids).delete_all
    puts "Done"

    puts "Creating and uploading manifest file..."
    manifest_filename = "events.manifest"
    manifest_file = Tempfile.new(manifest_filename)
    manifest_file.write JSON.pretty_generate(manifest)
    manifest_file.close
    bucket.object(manifest_filename).upload_file(manifest_file.path)
    puts "Done"

    puts "Connecting and loading the data to redshift..."
    PG.connect(
      host: Rails.application.secrets.redshift_host,
      port: 5439,
      user: Rails.application.secrets.redshift_user,
      password: Rails.application.secrets.redshift_password,
      dbname: Rails.application.secrets.redshift_dbname
    ).exec <<-EOS
      COPY events
      FROM 's3://#{bucket.name}/#{manifest_filename}'
      CREDENTIALS 'aws_access_key_id=#{Rails.application.secrets.s3_access_key_id};aws_secret_access_key=#{Rails.application.secrets.s3_secret_access_key}'
      CSV
      DELIMITER ';'
      TIMEFORMAT 'YYYY-MM-DD HH24:MI:SS'
      ACCEPTINVCHARS
      MANIFEST
      GZIP
    EOS
    puts "Done"

    puts "Cleaning up bucket..."
    bucket.clear!
    puts "All Done!"
  end

end

def zip events
  filename = "events_#{events.first.id}_to_#{events.last.id}.gz"
  file = Tempfile.new(filename)
  Zlib::GzipWriter.open(file) do |gz|
    csv_string = CSV.generate("", {col_sep: ";", quote_char: '"'}) do |csv|
      events.each do |event|
        csv << event.to_csv
        progressbar.increment
      end
    end
    gz.write csv_string
  end

  bucket.object(filename).upload_file(file.path)
end
