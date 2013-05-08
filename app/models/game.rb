class Game < ActiveRecord::Base




  ENGLISH_FREQ = { a: 8, b: 2, c: 3, d: 4, e: 12, f: 2, g: 2, h: 6, i: 7, j: 1,k: 1, l: 4, m: 3, n: 6, o: 8, p: 2, q: 1, r: 6, s: 6, t: 9, u: 3, v: 1, w: 2, x: 1, y: 2, z: 1 }

  def self.letter_freq_hash(lang)
    case lang
    when 'english'
      return ENGLISH_FREQ
    when 'spanish'
      return SPANISH_FREQ
    when 'vietnamese'
      return VIETNAMESE_FREQ
    end
  end 
end
