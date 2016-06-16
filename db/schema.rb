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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160616190422) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bins", force: :cascade do |t|
    t.string   "title"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "description"
    t.string   "abbreviation"
    t.integer  "position"
    t.string   "logo_file_name"
    t.string   "logo_content_type"
    t.integer  "logo_file_size"
    t.datetime "logo_updated_at"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.text     "message"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "feedbacks", ["user_id"], name: "index_feedbacks_on_user_id", using: :btree

  create_table "guide_positions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "bin_id"
    t.integer  "position",   default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "guide_positions", ["bin_id"], name: "index_guide_positions_on_bin_id", using: :btree
  add_index "guide_positions", ["user_id"], name: "index_guide_positions_on_user_id", using: :btree

  create_table "likes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "dislike",    default: false, null: false
  end

  add_index "likes", ["post_id"], name: "index_likes_on_post_id", using: :btree
  add_index "likes", ["user_id"], name: "index_likes_on_user_id", using: :btree

  create_table "participations", force: :cascade do |t|
    t.integer  "room_id",    null: false
    t.integer  "user_id",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  add_index "participations", ["deleted_at"], name: "index_participations_on_deleted_at", using: :btree
  add_index "participations", ["room_id"], name: "index_participations_on_room_id", using: :btree
  add_index "participations", ["user_id"], name: "index_participations_on_user_id", using: :btree

  create_table "post_bins", force: :cascade do |t|
    t.integer "post_id"
    t.integer "bin_id"
    t.integer "position"
  end

  add_index "post_bins", ["bin_id"], name: "index_post_bins_on_bin_id", using: :btree
  add_index "post_bins", ["post_id", "bin_id"], name: "index_post_bins_on_post_id_and_bin_id", using: :btree
  add_index "post_bins", ["post_id"], name: "index_post_bins_on_post_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.integer  "user_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "deleted_at"
    t.string   "link"
    t.string   "format_link"
    t.string   "format_type"
    t.text     "text_content"
    t.boolean  "sticky"
    t.string   "comment"
    t.integer  "editor_id"
    t.boolean  "live",         default: false, null: false
    t.integer  "bin_id"
    t.integer  "start_time"
    t.integer  "duration"
  end

  add_index "posts", ["bin_id"], name: "index_posts_on_bin_id", using: :btree
  add_index "posts", ["deleted_at"], name: "index_posts_on_deleted_at", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "rater_id"
    t.integer  "ratee_id"
    t.integer  "room_id"
    t.boolean  "nsfw"
    t.integer  "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "ratings", ["ratee_id"], name: "index_ratings_on_ratee_id", using: :btree
  add_index "ratings", ["rater_id"], name: "index_ratings_on_rater_id", using: :btree
  add_index "ratings", ["room_id", "rater_id", "ratee_id"], name: "index_ratings_on_room_id_and_rater_id_and_ratee_id", unique: true, using: :btree
  add_index "ratings", ["room_id"], name: "index_ratings_on_room_id", using: :btree

  create_table "reactions", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "post_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
  end

  add_index "reactions", ["post_id"], name: "index_reactions_on_post_id", using: :btree
  add_index "reactions", ["user_id"], name: "index_reactions_on_user_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.integer  "post_id"
    t.string   "token"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "deleted_at"
    t.boolean  "full",       default: false, null: false
    t.boolean  "waiting",    default: false, null: false
    t.boolean  "fresh",      default: false, null: false
    t.integer  "bin_id"
  end

  add_index "rooms", ["bin_id"], name: "index_rooms_on_bin_id", using: :btree
  add_index "rooms", ["deleted_at"], name: "index_rooms_on_deleted_at", using: :btree
  add_index "rooms", ["post_id"], name: "index_rooms_on_post_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "name"
    t.boolean  "banned",                 default: false, null: false
    t.boolean  "active"
    t.boolean  "matching",               default: true
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "feedbacks", "users"
  add_foreign_key "guide_positions", "bins"
  add_foreign_key "guide_positions", "users"
  add_foreign_key "likes", "posts"
  add_foreign_key "likes", "users"
  add_foreign_key "posts", "bins"
  add_foreign_key "reactions", "posts"
  add_foreign_key "reactions", "users"
  add_foreign_key "rooms", "bins"
end
