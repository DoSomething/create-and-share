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

ActiveRecord::Schema.define(:version => 20130802134554) do

  create_table "api_keys", :force => true do |t|
    t.string   "key"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "campaigns", :force => true do |t|
    t.string   "title"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "path"
    t.string   "lead"
    t.string   "lead_email"
    t.string   "developers"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "gated"
    t.text     "description"
    t.string   "image"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "mailchimp"
    t.string   "mobile_commons"
    t.string   "mailchimp_submit"
    t.string   "email_submit"
    t.string   "email_signup"
    t.string   "meme_header"
    t.boolean  "meme"
  end

  create_table "participations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "campaign_id"
    t.boolean  "intent"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "participations", ["campaign_id"], :name => "index_participations_on_campaign_id"
  add_index "participations", ["user_id", "campaign_id"], :name => "index_participations_on_user_id_and_campaign_id", :unique => true
  add_index "participations", ["user_id"], :name => "index_participations_on_user_id"

  create_table "posts", :force => true do |t|
    t.string   "image"
    t.string   "name"
    t.string   "state"
    t.boolean  "flagged",            :default => false
    t.boolean  "promoted",           :default => false
    t.integer  "share_count"
    t.text     "story"
    t.datetime "creation_time"
    t.datetime "update_time"
    t.boolean  "adopted"
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
    t.integer  "campaign_id"
    t.text     "extras"
  end

  add_index "posts", ["campaign_id"], :name => "index_posts_on_campaign_id"

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

  add_index "shares", ["post_id"], :name => "index_shares_on_post_id"

  create_table "tags", :force => true do |t|
    t.integer  "campaign_id"
    t.integer  "post_id"
    t.string   "column"
    t.string   "value"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "tags", ["campaign_id"], :name => "index_tags_on_campaign_id"
  add_index "tags", ["post_id"], :name => "index_tags_on_post_id"

  create_table "users", :force => true do |t|
    t.integer  "fbid",       :limit => 8
    t.integer  "uid",        :limit => 8
    t.string   "email"
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
    t.boolean  "is_admin"
    t.string   "mobile"
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false, :null => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "fk_one_vote_per_user_per_entity", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
