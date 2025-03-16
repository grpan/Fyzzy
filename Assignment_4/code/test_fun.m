for n=1:8
    get_dims(n)
end

function dims = get_dims(n)



p2 = ceil(sqrt(n));

p1 = ceil(n/p2);

dims = [p1 p2];
end

