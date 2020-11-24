# frozen_string_literal: true

# Proxy files through application with authentication.
# This avoids making the S3 bucket where files are stored public

# Overwriting
# https://github.com/rails/rails/blob/6-1-stable/activestorage/app/controllers/active_storage/blobs/proxy_controller.rb
class ActiveStorage::Blobs::ProxyController < ActiveStorage::BaseController
  include ActiveStorage::SetBlob
  include ActiveStorage::SetHeaders

  def show
    redirect_to('/') && return if current_user.nil? || current_user&.id != @blob&.attachments&.first&.record&.user_id

    http_cache_forever public: true do
      set_content_headers_from @blob
      stream @blob
    end
  end
end
