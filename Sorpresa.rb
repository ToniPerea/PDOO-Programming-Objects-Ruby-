#encoding: utf-8
module ModeloQytetet
  class Sorpresa
    attr_reader :sorpresa, :tipo, :valor
    def initialize(sorpresa, valor, tipo)
      @sorpresa = sorpresa
      @tipo = tipo
      @valor = valor
    end
    
    def to_s
      "Texto: #{@sorpresa} \n Valor: #{@valor} \n Tipo: #{@tipo}"
    end
  end
end