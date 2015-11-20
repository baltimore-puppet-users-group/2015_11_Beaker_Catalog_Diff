# diff_test

class diff_test (
  $param1 = ''
) {
  # This should be false in 3 and true in 4
  if $param1 {
    notify { 'I am param one the magnificent': }
  }
  else {
    notify { 'I am not the param you are looking for': }
  }
}
