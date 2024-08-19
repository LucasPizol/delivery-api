require "uri"

class AwsService 
    def initialize 
        if ENV["S3_PUBLIC_KEY"].nil? || ENV["S3_SECRET_KEY"].nil? || ENV["S3_URL"].nil? || ENV["S3_BUCKET"].nil?
            raise "S3_PUBLIC_KEY, S3_SECRET_KEY, S3_BUCKET and S3_URL must be set in .env file"
        end

        @aws_service = Aws::S3::Client.new(
            region: "sa-east-1",
            access_key_id: ENV['S3_PUBLIC_KEY'],
            secret_access_key: ENV['S3_SECRET_KEY'],
        )
    end


    def insert(file, path)
        initialize
        @aws_service.put_object(bucket: ENV['S3_BUCKET'], key: path, body: file, content_type: file.content_type, acl: 'public-read')
        "#{ENV['S3_URL']}#{path}"
    end
end 