# encoding: utf-8

# Türkçe alfabesi
def alfabe
  return 'ABCÇDEFGĞHIİJKLMNOÖPRSŞTUÜVYZ'
end

# Anahtarı, verilen metnin uzunluğu boyutuna getir.
def yeni_anahtar(sifrelenecek, anahtar)
  yeni_anahtar = ""

  sifrelenecek.size.times do |index|
    if sifrelenecek[index] == " "
      yeni_anahtar += " "
    else
      yeni_anahtar += anahtar[index%anahtar.size]
    end
  end
  return yeni_anahtar
end

# metin: Şifrelenecek metin
# anahtar: Şifrelemede kullanılacak anahtar
# sifrele: Bool türünde bir değişkendir.
#         "True" değerinde şifreleme
#         "False" değerinde çözme
def vigenere(metin, anahtar, sifrele)
  sonuc = ''
  index = 0
  anahtar = turkcelestir_ve_buyut(anahtar)
  anahtar = yeni_anahtar(metin, anahtar)
  metin = turkcelestir_ve_buyut(metin)
  metin.each_char do |harf|
    if alfabe.include? harf
      harf_index = alfabe.index(harf)
      anahtar_index = alfabe.index(anahtar[index])
      if sifrele
        islenmis_harf_index = (harf_index + anahtar_index) % alfabe.size
      else
        islenmis_harf_index = (harf_index - anahtar_index) % alfabe.size
      end
      harf = alfabe[islenmis_harf_index]
    end
    index += 1
    sonuc += harf
  end
  return sonuc
end

# Türkçe karakterleri idare et.
def turkcelestir_ve_buyut(metin)
  metin.gsub!("ğ","Ğ")
  metin.gsub!("i","İ")
  metin.gsub!("ç","Ç")
  metin.gsub!("ö","Ö")
  metin.gsub!("ü","Ü")
  metin.gsub!("ş","Ş")
  metin.gsub!("ı","I")
  metin.upcase!
  metin
end

# Verilen anahtar uzunluğunda, alfabeden üretilebilecek olası tüm anahtarları
# üretir.
def anahtar_listesi_olustur(anahtar_uzunlugu)
  anahtarlar = []
  anahtar_uzunlugu.times do |i|
    anahtarlar << alfabe.split("").repeated_permutation(i+1).map(&:join)
  end
  anahtarlar.flatten!
end

# sifreli_metin: Şifrelenmiş metin
# anahtar_uzunlugu: Denenecek maksimum anahtar uzunluğu
def brute_force(sifreli_metin, anahtar_uzunlugu)
  sifreli_metin = turkcelestir_ve_buyut(sifreli_metin)
  anahtarlar = anahtar_listesi_olustur(anahtar_uzunlugu)
  olasi_anahtarlar = {}
  anahtarlar.each do |anahtar|
    benzerlik = 0
    benzerlik_sayisi = 0
    kelimeler = vigenere(sifreli_metin, anahtar, false)
    kelimeler.split(" ").each do |kelime|
      # ---
      kelime_listesi.each do |liste_kelimesi|
        if kelime.size == liste_kelimesi.size
          if string_difference_percent(kelime, liste_kelimesi) <= 0.1
            benzerlik += string_difference_percent(kelime, liste_kelimesi)
            benzerlik_sayisi += 1
          end
        end
      end
      # ---
      #
      # if kelime_listesi.include? kelime
      #   benzerlik += 1
      # end

      # if benzerlik == kelimeler.split(" ").size
      #   puts "ok"
      # end

    end
    if benzerlik/kelimeler.split(" ").size <= 0.1 and benzerlik_sayisi == kelimeler.split(" ").size
      olasi_anahtarlar[anahtar] = benzerlik_sayisi
      # p olasi_anahtarlar
      break
    end
  end
  if !olasi_anahtarlar.empty?
    olasi_anahtar = olasi_anahtarlar.values.max
    olasi_anahtar = olasi_anahtarlar.invert[olasi_anahtar]
    # p "olası anahtar => " + olasi_anahtar
    # p vigenere(sifreli_metin.dup, olasi_anahtar.dup, false)
    return olasi_anahtar
  else
    p "olasi anahtar bulunamadi"
    return false
  end
end

# kelimelerin benzerliklerini oransal olarak hesapla.
# a, b: kıyaslanacak kelimeler
def string_difference_percent(a, b)
  longer = [a.size, b.size].max
  same = a.each_char.zip(b.each_char).select { |a,b| a == b }.size
  (longer - same) / a.size.to_f
end

# Brute-Force Attack'ta kullanılacak Türkçe'de en fazla kullanılan 1000 kelimeyi
# hazırla.
#
# Kaynak:
# http://tr.wiktionary.org/wiki/Vikis%C3%B6zl%C3%BCk:T%C3%BCrk%C3%A7e_temel_s%C3%B6zl%C3%BCk_(kullan%C4%B1m_s%C4%B1kl%C4%B1%C4%9F%C4%B1na_g%C3%B6re)
def kelime_listesi
  contents = File.read("sozluk.txt")
  contents = turkcelestir_ve_buyut(contents)
  contents = contents.split("\n")
  contents.map {|a| a.chomp! }
  contents
end

# Verilen Metnin Frekans Tablosunu verir.
def frekanslar(metin)
  tablo = {}
  metin = metni_ayikla(metin)
  metin.each_char do |harf|
    if tablo.include? harf
      tablo[harf] += 1
    else
      tablo[harf] = 1
    end
  end

  tablo.each do |i|
    tablo[i[0]] = 1.0 * i[1] / metin.size
  end

  return tablo
end

# "Şifrelerin Matematiği: Kriptografi" kitabındaki "Harflerin Kullanım
# Sıklıkları" Tablosu referans alınmıştır.
def turkce_frekans_tablosu
  { "A" => 0.121, "B" => 0.025, "C" => 0.009, "Ç" => 0.01, "D" => 0.041, "E" => 0.095, "F" => 0.005, "G" => 0.013, "Ğ" => 0.011,
    "H" => 0.011, "I" => 0.048, "İ" => 0.107, "J" => 0.0005, "K" => 0.047, "L" => 0.062, "M" => 0.037, "N" => 0.071, "O" => 0.022,
    "Ö" =>  0.007, "P" => 0.008, "R" => 0.068, "S" => 0.028, "Ş" => 0.016, "T" => 0.031, "U" => 0.029, "Ü" => 0.015, "V" =>  0.008,
    "Y" => 0.031, "Z" =>  0.014 }
end

# Dönüş değeri bir hash'tir. Metindeki harflerin frekans analizine göre hangi harflere karşılık
# geldiğini gösteren fonksiyondur.
def frekans_tablosunu_eslestir(ana_tablo)
  referans_tablo = turkce_frekans_tablosu.sort_by{|k,v| v}.reverse
  ana_tablo = ana_tablo.sort_by{|k,v| v}.reverse

  tahmin = {}
  ana_tablo.each_with_index do |item, index|
    tahmin[item[0]] = referans_tablo[index][0]
  end

  tahmin
end

# Verilen metindeki rakamları, boşlukları ve \n karakterini ve belli başlı
# noktalama işaretlerini siler.
def metni_ayikla(metin)
  metin.gsub!(/\d+/, '')
  metin.gsub!(" ", "")
  metin.gsub!("\n", "")
  special = "?<>',?[]}{=-)(*&^%$#`!~{}"
  regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
  metin.gsub!(regex, "")
  metin
end
# sifrelenecek = "işte öyle bir şey"
# anahtar = "AB"
# 
# p vigenere(sifrelenecek, anahtar, true)
# 
# p vigenere(vigenere(sifrelenecek, anahtar, true), "AB", false)
# 
# brute_force(vigenere(sifrelenecek, anahtar, true),3)
