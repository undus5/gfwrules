#!/usr/bin/ruby

require 'securerandom'
puts SecureRandom.urlsafe_base64(nil, false)
