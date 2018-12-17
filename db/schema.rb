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

ActiveRecord::Schema.define(version: 20181203134642) do

  create_table "candidates", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.string   "office",             limit: 255
    t.boolean  "show_on_ballot"
    t.boolean  "show_in_results"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.integer  "poll_id",            limit: 4
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.text     "description",        limit: 65535
    t.string   "slug",               limit: 255
  end

  add_index "candidates", ["name"], name: "index_candidates_on_name", using: :btree
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

  create_table "domains", force: :cascade do |t|
    t.string   "domain",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "poll_id",    limit: 4
  end

  add_index "domains", ["poll_id"], name: "index_domains_on_poll_id", using: :btree

  create_table "polls", force: :cascade do |t|
    t.string   "title",                            limit: 255
    t.string   "subtitle",                         limit: 255
    t.string   "short_name",                       limit: 255
    t.boolean  "end_voting"
    t.boolean  "show_results"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "instructions",                     limit: 255
    t.string   "name",                             limit: 255
    t.text     "email_template",                   limit: 65535
    t.string   "facebook_image_file_name",         limit: 255
    t.string   "facebook_image_content_type",      limit: 255
    t.integer  "facebook_image_file_size",         limit: 4
    t.datetime "facebook_image_updated_at"
    t.text     "results_text",                     limit: 65535
    t.text     "custom_css",                       limit: 65535
    t.string   "logo_file_name",                   limit: 255
    t.string   "logo_content_type",                limit: 255
    t.integer  "logo_file_size",                   limit: 4
    t.datetime "logo_updated_at"
    t.string   "actionkit_page",                   limit: 255
    t.string   "donation_url",                     limit: 255
    t.string   "twitter_text",                     limit: 255
    t.string   "vote_page_og_title",               limit: 255
    t.string   "results_page_og_title",            limit: 255
    t.string   "vote_page_og_description",         limit: 300
    t.string   "results_page_og_description",      limit: 300
    t.string   "share_vote_og_title",              limit: 255
    t.string   "share_vote_og_description",        limit: 300
    t.string   "promote_candidate_og_title",       limit: 255
    t.string   "promote_candidate_og_description", limit: 300
    t.text     "help_text",                        limit: 65535
    t.string   "from_line",                        limit: 255
    t.datetime "voting_ends_at"
  end

  create_table "votes", force: :cascade do |t|
    t.string   "email",               limit: 255
    t.string   "name",                limit: 255
    t.string   "zip",                 limit: 255
    t.string   "first_choice",        limit: 255
    t.string   "second_choice",       limit: 255
    t.string   "third_choice",        limit: 255
    t.string   "source",              limit: 255
    t.integer  "actionkit_id",        limit: 4
    t.string   "random_hash",         limit: 255
    t.string   "ip_address",          limit: 255
    t.string   "session_cookie",      limit: 255
    t.text     "full_querystring",    limit: 65535
    t.integer  "referring_vote_id",   limit: 4
    t.string   "referring_akid",      limit: 255
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "poll_id",             limit: 4
    t.string   "phone",               limit: 255
    t.boolean  "sms_opt_in"
    t.string   "auth_token",          limit: 255
    t.boolean  "verified_auth_token"
    t.string   "candidate_slug",      limit: 255
    t.boolean  "nonvalid",                          default: false, null: false
  end

  add_index "votes", ["email"], name: "index_votes_on_email", using: :btree
  add_index "votes", ["first_choice"], name: "index_votes_on_first_choice", using: :btree
  add_index "votes", ["nonvalid"], name: "index_votes_on_nonvalid", using: :btree
  add_index "votes", ["poll_id"], name: "index_votes_on_poll_id", using: :btree
  add_index "votes", ["second_choice"], name: "index_votes_on_second_choice", using: :btree
  add_index "votes", ["third_choice"], name: "index_votes_on_third_choice", using: :btree

end
