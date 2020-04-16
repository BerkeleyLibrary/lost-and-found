class FormsController < ApplicationController
    def search_form
      render :search_form
    end

    def item_search
        render :search_display
    end

    def insert_form
      render :insert_form
    end

end