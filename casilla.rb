#encoding: utf-8
require_relative "titulo_propiedad"

module ModeloQytetet
  class Casilla
    attr_reader :numeroCasilla, :tipo
    attr_accessor :coste
    def initialize(tipo, coste, numeroCasilla)
      @tipo = tipo
      @coste = coste
      @numeroCasilla = numeroCasilla
    end
    
    def self.newImpuesto(numeroCasilla, coste)
      new(TipoCasilla::IMPUESTO, coste, numeroCasilla)
    end
    
    def self.newSorpresa(numeroCasilla)
      new(TipoCasilla::SORPRESA, 0, numeroCasilla)
    end
    
    def self.newSalida(numeroCasilla)
      new(TipoCasilla::SALIDA, 1000, numeroCasilla)
    end
    
    def self.newJuez(numeroCasilla)
      new(TipoCasilla::JUEZ, 0, numeroCasilla)
    end
    
    def self.newParking(numeroCasilla)
      new(TipoCasilla::PARKING, 0, numeroCasilla)
    end
    
    def self.newCarcel(numeroCasilla)
      new(TipoCasilla::CARCEL, 0, numeroCasilla)
    end
    
    private_class_method :new
    
    def titulo
      return nil
    end
    
    def soyEdificable
      return false
    end
    
    def to_s
      texto = "Numero de la casilla: #{@numeroCasilla}\nCoste de la casilla: #{@coste}\nTipo de casilla: #{@tipo}\n"
       
      return texto
    end
  end
end
