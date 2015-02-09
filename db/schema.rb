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

ActiveRecord::Schema.define(version: 20150209183536) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candidates", force: :cascade do |t|
    t.string   "name"
    t.string   "office"
    t.boolean  "show_on_ballot"
    t.boolean  "show_in_results"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "poll_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
  end

  add_index "candidates", ["poll_id"], name: "index_candidates_on_poll_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "polls", force: :cascade do |t|
    t.string   "title"
    t.string   "subtitle"
    t.string   "short_name"
    t.boolean  "end_voting"
    t.boolean  "show_results"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "instructions"
    t.string   "name"
    t.text     "email_closure"
    t.string   "facebook_image_file_name"
    t.string   "facebook_image_content_type"
    t.integer  "facebook_image_file_size"
    t.datetime "facebook_image_updated_at"
    t.text     "results_text"
  end

  create_table "votes", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.string   "zip"
    t.string   "first_choice"
    t.string   "second_choice"
    t.string   "third_choice"
    t.string   "source"
    t.integer  "actionkit_id"
    t.string   "random_hash"
    t.string   "ip_address"
    t.string   "session_cookie"
    t.text     "full_querystring"
    t.integer  "referring_vote_id"
    t.string   "referring_akid"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.integer  "poll_id"
  end

  add_index "votes", ["poll_id"], name: "index_votes_on_poll_id", using: :btree

end
