module Virtualis
  class Report

    require 'csv'

    def self.parse(report_file)

      data = {
        :creation => [],
        :authorization => [],
        :compensation => [],
        :errors => []
      }

      csv = CSV.read(report_file, col_sep:';')
      header = csv.shift
      unless header[0] == 'ENREG'
        data[:errors] << "Invalid header for file #{report_file}: #{header.inspect}"
        return data
      end
      header = csv.shift
      file_date = DateTime.strptime("#{header[2]} CEST",'%d%m%Y %Z')
      unless header[0] == '01' and header[1] =~ /\AFICHIER QUOTIDIEN/
        data[:errors] << "Invalid header for file #{report_file}: #{header.inspect}"
        return data
      end
      footer = csv.pop
      unless footer[0] == '09' and footer[1] = csv.size - 2
        data[:errrors] << "Invalid footer for file #{report_file}: #{footer.inspect}"
        return data
      end

      csv.each do |line|
        item = {}
        begin
          if line[0] == '02'
            if line.size != 11
              raise ArgmentError, "Invalid number of items (#{line.size})"
            end
            item[:numero_carte] = line[1].gsub(/000\Z/, '')
            item[:etat] = line[2] == '0' ? 'active' : 'inactive'
            item[:montant_demande] = line[3].to_i
            item[:horodate_creation] = DateTime.strptime("#{line[4]} CEST", '%d%m%Y%H%M%S %Z')
            item[:nombre_autorisation] = line[5].to_i
            item[:montant_autorise] = line[6].to_i
            item[:identifiant_commerce] = line[7].to_i
            item[:nom_commerce] = line[8].gsub(/\\/, "\n")
            item[:horodate_derniere_autorisation] = DateTime.strptime("#{line[9]} CEST", '%d%m%Y%H%M%S %Z')
            data[:creation] << item
          elsif line[0] == '03'
            if line.size != 11
              raise ArgumentError, "Invalid number of items (#{line.size})"
            end
            item[:numero_carte] = line[1].gsub(/000\Z/, '')
            item[:numero_autorisation] = line[2].to_i
            item[:horodate_autorisation] = DateTime.strptime("#{line[3]} CEST", '%d%m%Y%H%M%S %Z')
            item[:code_reponse] = line[4].to_i
            item[:type_mouvement] = line[5].to_i
            item[:monnaie] = line[6].to_i
            item[:montant] = line[7].to_i
            item[:code_mcc] = line[8].to_i
            item[:identifiant_commerce] = line[9].to_i
            data[:authorization] << item
          elsif line[0] == '04'
            if line.size != 7
              raise ArugmentError, "Invalid number of items (#{line.size})"
            end
            item[:numero_carte] = line[1].gsub(/000\Z/, '')
            item[:horodate_operation] = DateTime.strptime("#{line[2]} CEST", '%d%m%Y%H%M%S %Z')
            item[:code_operation] = line[3].to_i
            item[:montant] = line[4].to_i
            item[:horodate_creation] = DateTime.strptime("#{line[2]} CEST", '%d%m%Y%H%M%S %Z')
            data[:compensation] << item
          else
            raise ArgumentError, "Invalid operation #{line[0]}"
          end
        rescue => e
          data[:errors] << "Error in #{report_file}, line #{line.inspect}: #{e.to_s}"
        end
      end
      return data
    end
  end

end
