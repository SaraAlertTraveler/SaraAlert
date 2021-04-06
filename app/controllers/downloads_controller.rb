# frozen_string_literal: true

# DownloadsController: for handling user downloads
class DownloadsController < ApplicationController
  include Rails.application.routes.url_helpers
  before_action :authenticate_user!, :current_user_download

  def download
    redirect_to root_url unless current_user.can_export?
    @export_url = rails_storage_proxy_path(@download.export_files.first)
  end

  # Hit this endpoint after the download link is clicked to remove download from database
  # and object storage
  def downloaded
    # This background job cannot be run when executing system tests because the exported file will be deleted before the system test can download it.
    return if @download.marked_for_deletion || Rails.configuration.x.executing_system_tests

    DestroyDownloadsJob.set(wait_until: ADMIN_OPTIONS['download_destroy_wait_time'].to_i.minute.from_now).perform_later(@download)
    @download.update(marked_for_deletion: true)
  end

  private

  def current_user_download
    @download = current_user.downloads.find_by!(id: params[:id])
  end
end
