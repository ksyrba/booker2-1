require 'rails_helper'

RSpec.describe 'Bookモデルのテスト', type: :model do
  describe 'バリデーションのテスト' do
    subject { book.valid? }

    let(:user) { create(:user) }
    let!(:book) { build(:book, user_id: user.id) }

    context 'titleカラム' do
      it '空欄でないこと' do
        book.title = ''
        is_expected.to eq false
      end
    end

    context 'bodyカラム' do
      it '空欄でないこと' do
        book.body = ''
        is_expected.to eq false
      end
      it '200文字以下であること: 200文字は〇' do
        book.body = Faker::Lorem.characters(number: 200)
        is_expected.to eq true
      end
      it '200文字以下であること: 201文字は×' do
        book.body = Faker::Lorem.characters(number: 201)
        is_expected.to eq false
      end
    end
  end

  describe 'アソシエーションのテスト' do
    context 'Userモデルとの関係' do
      it 'N:1となっている' do
        expect(Book.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end
  end
end

RSpec.describe Book, "モデルに関するテスト", type: :model do
  describe '実際に保存してみる' do
    it "有効な投稿内容の場合は保存されるか" do
      expect(FactoryBot.build(:book)).to be_valid
    end
  end
  context "空白のバリデーションチェック" do
    it "titleが空白の場合にバリデーションチェックされ空白のエラーメッセージが返ってきているか" do
      book = Book.new(title: '', body:'hoge')
      expect(book).to be_invalid
      expect(book.errors[:title]).to include("can't be blank")
    end
    it "bodyが空白の場合にバリデーションチェックされ空白のエラーメッセージが返ってきているか" do
      book = Book.new(title: 'hoge', body:'')
      expect(book).to be_invalid
      expect(book.errors[:body]).to include("can't be blank")
    end
  end
end

describe '投稿のテスト' do
let!(:book) { create(:book,title:'hoge',body:'body') }
describe 'トップ画面(root_path)のテスト' do
  before do
    visit root_path
  end
  context '表示の確認' do
    it 'トップ画面(root_path)に一覧ページへのリンクが表示されているか' do
      expect(page).to have_link "", href: books_path
    end
    it 'root_pathが"/"であるか' do
      expect(current_path).to eq('/')
    end
  end
end
describe "一覧画面のテスト" do
  before do
    visit books_path
  end
  context '一覧の表示とリンクの確認' do
    it "bookの一覧表示(tableタグ)と投稿フォームが同一画面に表示されているか" do
      expect(page).to have_selector 'table'
      expect(page).to have_field 'book[title]'
      expect(page).to have_field 'book[body]'
    end
    it "bookのタイトルと感想を表示し、詳細・編集・削除のリンクが表示されているか" do
        (1..5).each do |i|
          Book.create(title:'hoge'+i.to_s,body:'body'+i.to_s)
        end
        visit books_path
        Book.all.each_with_index do |book,i|
          j = i * 3
          expect(page).to have_content book.title
          expect(page).to have_content book.body
          # Showリンク
          show_link = find_all('a')[j]
          expect(show_link.native.inner_text).to match(/show/i)
          expect(show_link[:href]).to eq book_path(book)
          # Editリンク
          show_link = find_all('a')[j+1]
          expect(show_link.native.inner_text).to match(/edit/i)
          expect(show_link[:href]).to eq edit_book_path(book)
          # Destroyリンク
          show_link = find_all('a')[j+2]
          expect(show_link.native.inner_text).to match(/destroy/i)
          expect(show_link[:href]).to eq book_path(book)
        end
    end
    it 'Create Bookボタンが表示される' do
      expect(page).to have_button 'Create Book'
    end
  end
  context '投稿処理に関するテスト' do
    it '投稿に成功しサクセスメッセージが表示されるか' do
      fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
      fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
      click_button 'Create Book'
      expect(page).to have_content 'successfully'
    end
    it '投稿に失敗する' do
      click_button 'Create Book'
      expect(page).to have_content 'error'
      expect(current_path).to eq('/books')
    end
    it '投稿後のリダイレクト先は正しいか' do
      fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
      fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
      click_button 'Create Book'
      expect(page).to have_current_path book_path(Book.last)
    end
  end
  context 'book削除のテスト' do
    it 'bookの削除' do
      expect{ book.destroy }.to change{ Book.count }.by(-1)
      # ※本来はダイアログのテストまで行うがココではデータが削除されることだけをテスト
    end
  end
end
describe '詳細画面のテスト' do
  before do
    visit book_path(book)
  end
  context '表示の確認' do
    it '本のタイトルと感想が画面に表示されていること' do
      expect(page).to have_content book.title
      expect(page).to have_content book.body
    end
    it 'Editリンクが表示される' do
      edit_link = find_all('a')[0]
      expect(edit_link.native.inner_text).to match(/edit/i)
		end
    it 'Backリンクが表示される' do
      back_link = find_all('a')[1]
      expect(back_link.native.inner_text).to match(/back/i)
		end
  end
  context 'リンクの遷移先の確認' do
    it 'Editの遷移先は編集画面か' do
      edit_link = find_all('a')[0]
      edit_link.click
      expect(current_path).to eq('/books/' + book.id.to_s + '/edit')
    end
    it 'Backの遷移先は一覧画面か' do
      back_link = find_all('a')[1]
      back_link.click
      expect(page).to have_current_path books_path
    end
  end
end
describe '編集画面のテスト' do
  before do
    visit edit_book_path(book)
  end
  context '表示の確認' do
    it '編集前のタイトルと感想がフォームに表示(セット)されている' do
      expect(page).to have_field 'book[title]', with: book.title
      expect(page).to have_field 'book[body]', with: book.body
    end
    it 'Update Bookボタンが表示される' do
      expect(page).to have_button 'Update Book'
    end
    it 'Showリンクが表示される' do
      show_link = find_all('a')[0]
      expect(show_link.native.inner_text).to match(/show/i)
		end
    it 'Backリンクが表示される' do
      back_link = find_all('a')[1]
      expect(back_link.native.inner_text).to match(/back/i)
		end
  end
  context 'リンクの遷移先の確認' do
    it 'Showの遷移先は詳細画面か' do
      show_link = find_all('a')[0]
      show_link.click
      expect(current_path).to eq('/books/' + book.id.to_s)
    end
    it 'Backの遷移先は一覧画面か' do
      back_link = find_all('a')[1]
      back_link.click
      expect(page).to have_current_path books_path
    end
  end
  context '更新処理に関するテスト' do
    it '更新に成功しサクセスメッセージが表示されるか' do
      fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
      fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
      click_button 'Update Book'
      expect(page).to have_content 'successfully'
    end
    it '更新に失敗しエラーメッセージが表示されるか' do
      fill_in 'book[title]', with: ""
      fill_in 'book[body]', with: ""
      click_button 'Update Book'
      expect(page).to have_content 'error'
    end
    it '更新後のリダイレクト先は正しいか' do
      fill_in 'book[title]', with: Faker::Lorem.characters(number:5)
      fill_in 'book[body]', with: Faker::Lorem.characters(number:20)
      click_button 'Update Book'
      expect(page).to have_current_path book_path(book)
    end
  end
end
end
