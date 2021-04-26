//
//  UIButtonExtension.swift
//  iOS Calculadora 2
//
//  Created by Nicolas Russi on 5/04/21.
//

import UIKit

private let orange = UIColor(red: 254/255, green: 148/255, blue: 8/255, alpha: 1)

extension UIButton {
    //Borde redondo de los botones
    func round()  {
        layer.cornerRadius = bounds.height / 2
        clipsToBounds = true
    }
    
    //Brilla
    func shine() {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = 0.5
        }) { (completion) in
            UIView.animate(withDuration: 0.1, animations: {
                self.alpha = 1
            })
        }
    }
    
    //seleccion de boton de operacion (para ver cuando seleccionamos un boton)
    func selectOperation(_ selected:Bool) {
        //si seleccionados el fondo sera blanco si no sera anaranjado
        backgroundColor = selected ? .white : orange
        //si esta seleccionado el texto sera naranaja si no sera blanco
        setTitleColor(selected ? orange : .white, for: .normal)
    }
}
