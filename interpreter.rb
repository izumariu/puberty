FNAME = ARGV[0] ; ARGV.clear
BNAME = FNAME.match(/(.+)\.[^.]+$/)[1]
$CONTENT = open(FNAME,?r).read.strip.split(?.)
$REGS = [0, 0, 0, 0, 0, 0]
$REGPTR = 0
$IPTR = 0
PRONOUNS={
  m:{personal:"[Hh]e",   possessive:"[Hh]is",   relative:"[Hh]im",  verb_suffix:"s"},
  f:{personal:"[Ss]he",  possessive:"[Hh]er",   relative:"[Hh]er",  verb_suffix:"s"},
  a:{personal:"[Tt]hey", possessive:"[Tt]heir", relative:"[Tt]hem", verb_suffix:"" }
}

->{
  _months = %w(January February March April May June July August September October November December)
  _phrase = $CONTENT.shift.strip
  _rxp=Regexp.new("^It\\s+is\\s+(#{_months.join(?|)})\\s+(\\d{,2})(st|nd|th)?,\\s+(\\d{4}),\\s+(\\d{,2}):(\\d{,2}):(\\d{,2})\\s+([AP]M)$", Regexp::MULTILINE)
  _m = _phrase.match _rxp
  _m||abort("OOPS WRONG SYNTAX IN FIRST INTRO SENTENCE")
  $REGS[3] = Time.new(
    _m[4].to_i,
    _months.index(_m[1])+1,
    _m[2].to_i,
    ( _m[8]=="AM" ? (_m[5]=="12" ? 0 : _m[5].to_i) : (_m[5]=="12" ? 12 : (12+_m[5].to_i)) ),
    _m[6].to_i,
    _m[7].to_i,
    0
  ).to_i%256
}.call

->{
  _phrase = $CONTENT.shift.strip
  _rxp=Regexp.new("^(.+)\\s+is\\s+in\\s+(his|her|their)\\s+bed,\\s+bored$", Regexp::MULTILINE)
  _m = _phrase.match _rxp
  _m||abort("OOPS WRONG SYNTAX IN SECOND INTRO SENTENCE")
  $REGS[2] = _m[1].length
  GENDER=(case _m[2];when "his";:m;when "her";:f;when "their";:a;end)
}.call

->{
  _phrase = $CONTENT.shift.strip
  _rxp=Regexp.new("#{PRONOUNS[GENDER][:possessive]}\\s+secret\\s+kinks?\\s+(is|are)\\s+(.+)$", Regexp::MULTILINE)
  _m = _phrase.match _rxp
  _m||abort("OOPS WRONG SYNTAX IN THIRD INTRO SENTENCE")
  _plural=(_m[1]=="are")
  _kinks = _m[2].split(/\s*,\s*|\s*and\s*/)
  _plural ? (_kinks.length>1 ? (KINKS=_kinks.reverse.map(&:downcase)) : abort("OOPS WRONG SYNTAX IN THIRD INTRO SENTENCE")) : (_kinks.length==1 ? (KINKS=_kinks.map(&:downcase)) : abort("OOPS WRONG SYNTAX IN THIRD INTRO SENTENCE"))
  $COOLDOWNS = Hash.new
  KINKS.each_with_index{|k,i|$COOLDOWNS.store(k,0)}
}.call

->{
  _phrase = $CONTENT.shift.strip
  if _phrase.match /^(Then|Suddenly)\\s+the/
    _rxp=Regexp.new("^(Then|Suddenly)\\s+#{PRONOUNS[GENDER][:personal]}\\s+spot#{PRONOUNS[GENDER][:verb_suffix]}\\s+(.+)$", Regexp::MULTILINE)
    _m = _phrase.match _rxp
    _m||abort("OOPS WRONG SYNTAX IN FOURTH INTRO SENTENCE (#{_phrase.inspect})")
    $REGS[0] = 2**(KINKS.index(_m[2].downcase)+2)
  else
    $CONTENT.unshift _phrase
  end
}.call

->{
  _phrase = $CONTENT.shift.strip
  _rxp=Regexp.new("^(Soon|Then|Suddenly)\\s+the\\s+following\\s+sounds\\s+become\\s+audible$", Regexp::MULTILINE)
  _m = _phrase.match _rxp
  _m||abort("OOPS WRONG SYNTAX IN #{$REGS[0]==0 ? "FOURTH" : "FIFTH"} INTRO SENTENCE (#{_phrase.inspect})")
}.call

$CONTENT = $CONTENT.join(".").gsub(/ngh.+hhh/,"").gsub(/\s+/," ").strip.split
$RETSTACK= []

unless $CONTENT.select{|i|i.match(/^hrg$/i)}.length == $CONTENT.select{|i|i.match(/^mmf$/i)}.length
  abort("ERROR: MISMATCHED LOOP MARKERS")
end

#p $REGS

until $IPTR == $CONTENT.length
  case $CONTENT[$IPTR]
  when /^fap$/i
    $REGS[$REGPTR] += 1
    $COOLDOWNS = $COOLDOWNS.to_a.map{|i|i[1]-=1;i[1]<0&&i[1]=0;i}.to_h
  when /^ugh$/i
    $REGS[$REGPTR] = 0
  when Regexp.new("^(#{KINKS.join(?|)}),fuck$",Regexp::IGNORECASE)
    if $COOLDOWNS[$1.downcase] == 0
      $REGS[$REGPTR] += KINKS.index($1.downcase)+2
      $COOLDOWNS[$1.downcase] = 2**KINKS.index($1.downcase)
    else
      abort("ERROR: COOLDOWN DIDN'T EXPIRE ON #{$1.upcase.inspect}(WAS #{$COOLDOWNS[$1.downcase]} WHEN CALL OCCURRED)")
    end
  when Regexp.new("^(#{KINKS.join(?|)}),hnng$",Regexp::IGNORECASE)
    if $COOLDOWNS[$1.downcase] == 0
      $REGS[$REGPTR] += 2**(KINKS.index($1.downcase)+2)
      $COOLDOWNS[$1.downcase] = 2**(KINKS.index($1.downcase)+1)
    else
      abort("ERROR: COOLDOWN DIDN'T EXPIRE ON #{$1.upcase.inspect}(WAS #{$COOLDOWNS[$1.downcase]} WHEN CALL OCCURRED)")
    end
  when /^yeah$/i
    $REGPTR += 1
  when /^yes$/i
    putc $REGS[$REGPTR]
  when /^oh$/i
    $REGS[$REGPTR] = gets.chomp[0].ord
  when /^hrg$/i
    unless $REGS[$REGPTR] == 0
      $RETSTACK << $IPTR
    else

      ->{

        _depth = $RETSTACK.length
        _current = _depth+1
        until _depth == _current
          $IPTR += 1
          $CONTENT[$IPTR].match(/^hrg$/i)&&(_current+=1;next)
          $CONTENT[$IPTR].match(/^mmf$/i)&&(_current-=1;next)
        end

      }.call

    end
  when /^mmf$/i
    $REGS[$REGPTR] == 0 ? $RETSTACK.pop : $IPTR=$RETSTACK[-1]
  when /^squirt$/i
    6.times{putc($REGS[$REGPTR]);$REGPTR+=1;$REGPTR%=$REGS.length}
  when /^OMGMOMGETOUTTAHERE$/, /^sigh$/i
    exit
  else
    abort "UNKNOWN COMMAND #{$CONTENT[$IPTR].inspect}"
  end
  $REGPTR %= $REGS.length
  $REGS[$REGPTR] %= 256
  $IPTR += 1
end
