# frozen_string_literal: true

require 'spec_helper'

describe ConferencesController do
  let(:conference) { create(:conference, splashpage: create(:splashpage, public: true), venue: create(:venue)) }
  let!(:cfp) { create(:cfp, program: conference.program) }
  let(:room) { create(:room, venue: conference.venue) }

  describe 'GET #index' do
    it 'Response code is 200' do
      get :index
      expect(response.response_code).to eq(200)
    end
  end

  describe 'GET #show' do
    context 'conference made public' do
      it 'assigns the requested conference to conference' do
        get :show, params: { id: conference.short_title }
        expect(assigns(:conference)).to eq conference
      end

      it 'renders the show template' do
        get :show, params: { id: conference.short_title }
        expect(response).to render_template :show
      end
    end

    context 'accessing conference via custom domain' do
      before do
        conference.update_attribute(:custom_domain, 'lvh.me')
        @request.host = 'lvh.me'
      end

      it 'assigns correct conference' do
        get :show

        expect(response).to render_template :show
        expect(assigns(:conference)).to eq conference
      end
    end
  end

  describe 'GET #calendar' do
    it 'outputs conference text as written' do
      conference.update!(title: 'Con <%= 6 * 7 %>')
      sign_in create(:admin)

      get :calendar, format: :ics

      expect(response.media_type).to eq('text/calendar')
      expect(response.body).to include('Con <%= 6 * 7 %>')
      expect(response.body).not_to include('Con 42')
    end
  end

  describe 'OPTIONS #index' do
    it 'Response code is 200' do
      process :index
      expect(response.response_code).to eq(200)
    end
  end

end
