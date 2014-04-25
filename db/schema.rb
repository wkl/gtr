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

ActiveRecord::Schema.define(version: 20140424070446) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hops", force: true do |t|
    t.integer  "traceroute_id"
    t.integer  "no"
    t.string   "from",          limit: 40
    t.float    "rtt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "hops", ["traceroute_id"], name: "index_hops_on_traceroute_id", using: :btree

  create_table "traceroutes", force: true do |t|
    t.string   "uuid",       limit: 40
    t.string   "src",        limit: 40
    t.string   "dst",        limit: 40
    t.string   "dst_addr",   limit: 40
    t.boolean  "submitted"
    t.boolean  "available"
    t.boolean  "failed"
    t.datetime "endtime"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "probe",      limit: 10
  end

  add_index "traceroutes", ["uuid"], name: "index_traceroutes_on_uuid", unique: true, using: :btree

end
