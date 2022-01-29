function validate_html --argument path
    set -l response (string trim (https "https://validator.w3.org/nu/?out=gnu" @$path "Content-Type: text/html; charset=utf-8" --print 'b' --ignore-stdin))
    if test -n "$response"
        echo "$path: found errors or warnings"
        echo $response
        return 1
    else
        echo "$path: no errors or warnings"
        return 0
    end
end
