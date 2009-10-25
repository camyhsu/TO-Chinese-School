#
# Utility method for generating random string
# 

def random_string(length=10)
  chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
  random_string = ''
  length.times { random_string << chars[rand(chars.size)] }
  random_string
end

def random_uri
  '/' + random_string(5) + '/' + random_string(7)
end