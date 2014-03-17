# encoding: utf-8

require 'test/unit'
require_relative "vigenere"

class TestAdd < Test::Unit::TestCase
  def test_vigenere_cyrpt
    expected = vigenere("ANKARA", "ODTÜ", true)
    assert_equal expected, "ORGÜĞD"

    expected = vigenere("İŞTE ÖYLE BİR ŞEY", "AB", true)
    assert_equal expected, "İTTF PYME BJR ŞFY"

    expected = vigenere("HAYAT ÇOK ZOR GERÇEKTEN", "LAN", true)
    assert_equal expected, "TALLT OOA ZDE TPRPPKIPN"
  end

  def test_vigenere_decrypt
    expected = vigenere("ORGÜĞD", "ODTÜ", false)
    assert_equal expected, "ANKARA"

    expected = vigenere("İTTF PYME BJR ŞFY", "AB", false)
    assert_equal expected, "İŞTE ÖYLE BİR ŞEY"

    expected = vigenere("TALLT OOA ZDE TPRPPKIPN", "LAN", false)
    assert_equal expected, "HAYAT ÇOK ZOR GERÇEKTEN"

  end

  def test_brute_force
    expected = brute_force("İTTF PYME BJR ŞFY", 3)
    assert_equal expected, "AB" # Beklenildiği gibi bu anahtarı vermesi gerekir.
  end
end
