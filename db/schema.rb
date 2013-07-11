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

ActiveRecord::Schema.define(:version => 20130610145920) do

  create_table "api_keys", :force => true do |t|
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "posts", :force => true do |t|
    t.string   "image"
    t.string   "name"
    t.string   "animal_type"
    t.string   "state"
    t.string   "shelter"
    t.boolean  "flagged",            :default => false
    t.boolean  "promoted",           :default => false
    t.integer  "share_count"
    t.text     "story"
    t.datetime "creation_time"
    t.datetime "update_time"
    t.boolean  "adopted"
    t.string   "top_text"
    t.string   "bottom_text"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.integer  "uid"
    t.string   "meme_text"
    t.string   "meme_position"
    t.string   "city"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "shares", :force => true do |t|
    t.integer  "uid"
    t.integer  "post_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "fbid",       :limit => 8
    t.integer  "uid",        :limit => 8
    t.string   "email"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.boolean  "is_admin"
    t.boolean  "intent"
  end

end
