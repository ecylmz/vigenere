# encoding: utf-8

require "gtk2"
require_relative "vigenere"

class VigenereGtk
  def initialize
    @window = Gtk::Window.new
    @window.set_title "Vigenere"
    @window.set_size_request(725, 400)
    @window.set_resizable(false)
    @window.signal_connect('destroy'){Gtk.main_quit}
    @window.set_window_position(Gtk::Window::POS_CENTER)
    @output = Gtk::TextView.new
    @output.set_wrap_mode(Gtk::TextTag::WRAP_WORD)
    @input = Gtk::TextView.new
    @input.set_wrap_mode(Gtk::TextTag::WRAP_WORD)
    @key = Gtk::Entry.new
    window_contain
    @window.show_all
  end

  def window_contain
    @window.set_border_width 15

    table = Gtk::Table.new 15, 15, false
    table.set_column_spacings 3

    input_title = Gtk::Label.new "Girdi"
    halign2 = Gtk::Alignment.new 0, 0, 0, 0
    halign2.add input_title
    table.attach(halign2, 0, 1, 0, 1, Gtk::FILL, Gtk::FILL, 0, 0)
    @input.set_size_request 500, 150
    table.attach(@input, 0, 1, 1, 2, Gtk::FILL, Gtk::FILL, 0, 0)

    key_title = Gtk::Label.new "Anahtar / Anahtar Boyutu"
    halign3 = Gtk::Alignment.new 0, 0, 0, 0
    halign3.add key_title
    table.attach(halign3, 0, 1, 2, 3, Gtk::FILL, Gtk::FILL, 0, 0)
    table.attach(@key, 0, 1, 3, 4, Gtk::FILL, Gtk::FILL, 0, 0)

    output_title = Gtk::Label.new "Çıktı"
    halign1 = Gtk::Alignment.new 0, 0, 0, 0
    halign1.add output_title
    table.attach(halign1, 0, 1, 6, 7, Gtk::FILL, Gtk::FILL, 0, 0)
    @output.set_size_request 500, 150
    table.attach(@output, 0, 1, 7, 8, Gtk::FILL, Gtk::FILL, 0, 0)

    activate = Gtk::Button.new "Şifrele"
    activate.set_size_request 80, 30
    table.attach(activate, 2, 3, 1, 2, Gtk::FILL, Gtk::SHRINK, 1, 1)
    activate.signal_connect "clicked" do
      vigenere_window(true)
    end

    activate = Gtk::Button.new "Çöz"
    activate.set_size_request 80, 30
    table.attach(activate, 3, 4, 1, 2, Gtk::FILL, Gtk::SHRINK, 1, 1)
    activate.signal_connect "clicked" do
      vigenere_window(false)
    end

    activate = Gtk::Button.new "Kaba Kuvvet"
    activate.set_size_request 95, 30
    table.attach(activate, 2, 3, 2, 6, Gtk::FILL, Gtk::SHRINK, 1, 1)
    activate.signal_connect "clicked" do
      brute_force_window
    end

    activate = Gtk::Button.new "Frk. Analizi"
    activate.set_size_request 95, 30
    table.attach(activate, 3, 4, 2, 6, Gtk::FILL, Gtk::SHRINK, 1, 1)
    activate.signal_connect "clicked" do
      frekans_window
    end

    @window.add table
  end

  def vigenere_window(sifrele)
    special = "?<>',?[]}{=-)(*&^%$#`!~{}"
    regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
    if @key.text =~ /\d/ or @key.text =~ regex
      md = Gtk::MessageDialog.new(@window,
                                  Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                  Gtk::MessageDialog::BUTTONS_CLOSE, "Anahtar Yalnızca Türkçe Alfabedeki Harflerden Oluşmalıdır!")
      md.run
      md.destroy
      return nil
    end
    if @key.text.size == 0
      md = Gtk::MessageDialog.new(@window,
                                  Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                  Gtk::MessageDialog::BUTTONS_CLOSE, "Lütfen Bir Anahtar Giriniz!")
      md.run
      md.destroy
      return nil
    end
    if @input.buffer.text.size > @key.text.size
      p vigenere(@input.buffer.text, @key.text, sifrele)
      @output.buffer.text = vigenere(@input.buffer.text, @key.text, sifrele)
      return nil
    else
      md = Gtk::MessageDialog.new(@window,
                                  Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                  Gtk::MessageDialog::BUTTONS_CLOSE, "Anahtar Uzunluğu Girdiden Daha Uzun Olamaz!")
      md.run
      md.destroy
      return nil
    end
  end

  def brute_force_window
    special = "?<>',?[]}{=-)(*&^%$#`!~{}"
    regex = /[#{special.gsub(/./){|char| "\\#{char}"}}]/
    if @key.text =~ regex
      md = Gtk::MessageDialog.new(@window,
                                  Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                  Gtk::MessageDialog::BUTTONS_CLOSE, "Anahtar Uzunluğu Bir Sayı Olmalı!")
      md.run
      md.destroy
      return nil
    end
      if @key.text.to_i == 0
        md = Gtk::MessageDialog.new(@window,
                                    Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                    Gtk::MessageDialog::BUTTONS_CLOSE, "Anahtar Uzunluğu Bir Sayı Olmalı!")
        md.run
        md.destroy
        return nil
      end
      if anahtar = brute_force(@input.buffer.text, @key.text.to_i)
        md = Gtk::MessageDialog.new(@window,
                                    Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                    Gtk::MessageDialog::BUTTONS_CLOSE, "Bulunan Anahtar: #{anahtar.dup}")
        md.run
        md.destroy
        @output.buffer.text = vigenere(@input.buffer.text.dup, anahtar.dup, false)
        return nil
      else
        md = Gtk::MessageDialog.new(@window,
                                    Gtk::Dialog::MODAL, Gtk::MessageDialog::WARNING,
                                    Gtk::MessageDialog::BUTTONS_CLOSE, "Olası Anahtar Bulunamadı!")
        md.run
        md.destroy
        return nil
      end
  end

  def frekans_window
    frekans_tablosu = frekanslar(@input.buffer.text)
    tahmin_tablosu = frekans_tablosunu_eslestir(frekans_tablosu)
    @output.buffer.text = frekans_tablosu.to_s
    @output.buffer.text += "\n\n"
    tahmin_tablosu.each do |key, value|
      @output.buffer.text += "#{key} => #{value} \t"
    end
  end
end

app = VigenereGtk.new
Gtk.main
