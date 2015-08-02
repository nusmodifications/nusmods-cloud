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

ActiveRecord::Schema.define(version: 20150802082121) do

  create_table "timetables", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "semester",   limit: 255
    t.text     "lessons",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "timetables", ["user_id"], name: "index_timetables_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "nusnet_id",           limit: 255, null: false
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.string   "gender",              limit: 255
    t.string   "faculty",             limit: 255
    t.string   "first_major",         limit: 255
    t.string   "second_major",        limit: 255
    t.integer  "matriculation_year",  limit: 4
    t.string   "ivle_token",          limit: 255
    t.string   "access_token_digest", limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "users", ["nusnet_id"], name: "index_users_on_nusnet_id", unique: true, using: :btree

  add_foreign_key "timetables", "users"
end
