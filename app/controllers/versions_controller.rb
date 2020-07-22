class VersionsController < ApplicationController
  before_action :require_user
  before_action :set_document_and_version, only: %i[diff rollback destroy]

  def diff; end

  def rollback
    # change the current document to the specified version
    # reify gives you the object of this version
    document = @version.reify
    document.save
    redirect_to edit_document_path(document)
  end

  private

  def set_document_and_version
    @document = Document.find(params[:document_id])
    @version = @document.versions.find(params[:id])
  end

end
