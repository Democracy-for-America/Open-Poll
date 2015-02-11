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

ActiveRecord::Schema.define(version: 20150210201103) do

  create_table "candidates", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "office",             limit: 255
    t.boolean  "show_on_ballot",     limit: 1
    t.boolean  "show_in_results",    limit: 1
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "poll_id",            limit: 4
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
  end

  add_index "candidates", ["poll_id"], name: "index_candidates_on_poll_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "polls", force: :cascade do |t|
    t.string   "title",                       limit: 255
    t.string   "subtitle",                    limit: 255
    t.string   "short_name",                  limit: 255
    t.boolean  "end_voting",                  limit: 1
    t.boolean  "show_results",                limit: 1
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.string   "instructions",                limit: 255
    t.string   "name",                        limit: 255
    t.text     "email_template",              limit: 65535
    t.string   "facebook_image_file_name",    limit: 255
    t.string   "facebook_image_content_type", limit: 255
    t.integer  "facebook_image_file_size",    limit: 4
    t.datetime "facebook_image_updated_at"
    t.text     "results_text",                limit: 65535
    t.text     "custom_css",                  limit: 65535
    t.string   "logo_file_name",              limit: 255
    t.string   "logo_content_type",           limit: 255
    t.integer  "logo_file_size",              limit: 4
    t.datetime "logo_updated_at"
  end

  create_table "votes", force: :cascade do |t|
    t.string   "email",             limit: 255
    t.string   "name",              limit: 255
    t.string   "zip",               limit: 255
    t.string   "first_choice",      limit: 255
    t.string   "second_choice",     limit: 255
    t.string   "third_choice",      limit: 255
    t.string   "source",            limit: 255
    t.integer  "actionkit_id",      limit: 4
    t.string   "random_hash",       limit: 255
    t.string   "ip_address",        limit: 255
    t.string   "session_cookie",    limit: 255
    t.text     "full_querystring",  limit: 65535
    t.integer  "referring_vote_id", limit: 4
    t.string   "referring_akid",    limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "poll_id",           limit: 4
  end

  add_index "votes", ["poll_id"], name: "index_votes_on_poll_id", using: :btree

end
