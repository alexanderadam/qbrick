require 'spec_helper'

describe 'pages#index', type: :feature do
  context 'with search parameter' do
    let! :page1 do
      main_page = nil
      I18n.with_locale(:en) do
        main_page = create :page, published: 1, title: 'Chromodorididae Ardeadoris'
        main_page.bricks << Qbrick::TextBrick.new(locale: I18n.locale,
                                                  text: "#{'foo bar' * 300} Chromodorididae #{'foo bar' * 300}")
        main_page.save!
      end
      main_page
    end

    let! :page2 do
      I18n.with_locale(:en) do
        create :page, published: 1, title: 'Chromodorididae Berlanguella'
      end
    end

    let! :page3 do
      I18n.with_locale(:en) do
        create :page, published: 1, title: 'Gastropoda'
      end
    end

    context 'with fulltext' do
      before do
        visit qbrick.pages_path(locale: :en, search: 'Chromodorididae')
      end

      it 'highlights search term in preview' do
        within('ul.search-results.success') do
          expect(page).to have_content('Chromodorididae')
        end
      end

      it 'truncates the text' do
        expect(find('.summary .excerpt').text.length).to eq(110)
      end
    end

    context 'with multiple matches' do
      before do
        visit qbrick.pages_path(locale: :en, search: 'Chromodorididae')
      end

      it 'renders match count' do
        expect(page).to have_content('2 results')
      end

      it 'renders the search results list' do
        within('ul.search-results.success') do
          expect(page).to have_content('Chromodorididae Ardeadoris')
          expect(page).to have_content('Chromodorididae Berlanguella')
          expect(page).not_to have_content('Gastropoda')
        end
      end

      it 'renders links to the pages' do
        within('ul.search-results.success') do
          expect(page).to have_link('Chromodorididae Ardeadoris', href: page1.link)
          expect(page).to have_link('Chromodorididae Berlanguella', href: page2.link)
        end
      end
    end

    context 'without matches' do
      it 'renders match count' do
        visit qbrick.pages_path(locale: :en, search: 'foobar')
        expect(page).to have_content('No results')
      end
    end
  end
end
