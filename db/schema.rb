# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130507182741) do

  create_table "common_dictionaries", :force => true do |t|
    t.string   "word"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "common_dictionaries", ["word"], :name => "index_common_dictionaries_on_word"

  create_table "full_dictionaries", :force => true do |t|
    t.string   "word"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "full_dictionaries", ["word"], :name => "index_full_dictionaries_on_word"

  create_table "languages", :force => true do |t|
    t.string   "name"
    t.integer  "common_dictionary_id"
    t.integer  "full_dictionary_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "languages", ["common_dictionary_id"], :name => "index_languages_on_common_dictionary_id"
  add_index "languages", ["full_dictionary_id"], :name => "index_languages_on_full_dictionary_id"

end
