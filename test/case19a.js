# From Rosetta code website

function factors(num)
{
 var
  n_factors = [],
  i;
 
 for (i = 1; i <= Math.floor(Math.sqrt(num)); i += 1)
  if (num % i === 0)
  {
   n_factors.push(i);
   if (num / i !== i)
    n_factors.push(num / i);
  }
 n_factors.sort(function(a, b){return a - b;});  // numeric sort
 return n_factors;
}

function isPrime(num) {
    if (num <= 12) return (
        num == 2 || num == 3 || num == 5 || num == 7 || num == 11
    );
    if (num % 2 == 0 || num % 3 == 0 || num % 5 == 0 || num % 7 == 0)
        return false;
    for (var i = 10; i * i <= num; i += 10) {
        if (num % (i + 1) == 0) return false;
        if (num % (i + 3) == 0) return false;
        if (num % (i + 7) == 0) return false;
        if (num % (i + 9) == 0) return false;
    }
    return true;
}

function reverseString(s) {
  return s.split('\n').map(
    function (line) {
      return line.split(/\s/).reverse().join(' ');
    }
  ).join('\n');
}
