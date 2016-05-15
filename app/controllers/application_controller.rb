require 'net/http'
require 'json'

class ApplicationController < ActionController::Base

  def parametros

    tag =params[:tag]
    access_token = params[:access_token]
    uriCantidad= 'https://api.instagram.com/v1/tags/' + tag.to_s + '?access_token=' + access_token.to_s
    uri= 'https://api.instagram.com/v1/tags/'+ tag.to_s + '/media/recent?access_token='+ access_token.to_s
    cantidad = get(uriCantidad)
    media = get(uri)
    respuesta = crearDatos(cantidad, media)
    render json: respuesta, root: false

  end

  def get(uri)
    uri = URI.parse(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl=true
    request = Net::HTTP::Get.new(uri.request_uri)
    respuesta = http.request(request)
    return JSON.parse(respuesta.body)
    rescue JSON::ParserError
    return {}
  end
  
  def crearDatos(cantidad, media)
    respuesta={ "metadata" => {},
                "posts" => [],
                "version" => ""
    }
    respuesta['metadata']={'total' => cantidad['data']['media_count']}
    respuesta['version'] = '1.2'
    media['data'].each do |item| 
    respuesta['posts']<<{
     'tags'=> item['tags'],
     'username' => item['user']['username'],
     'likes'=> item['likes']['count'],
     'url'=> item['images']['standard_resolution']['url'], #siempre hay standard resolution
     'caption' =>  item['caption']['text']
    }
    #:Bad_request para lo del error de 400
    return respuesta
    
  end

  def maximaResolucion(imagen) #no es necesario 
  	
    if imagen.has_key?('standard_resolution')
      return imagen['standard_resolution']['url']
    elsif imagen.has_key?('low_resolution')
      return imagen['low_resolution']['url']
    else
      return imagen['thumbnail']['url']
    end
    return {}
  end
      
end
  #protect_from_forgery with: :exception


end