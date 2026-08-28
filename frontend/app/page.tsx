'use client';
import { useState } from 'react';

export default function WorkshopsPage() {
  const [talleres, setTalleres] = useState([
    { id: 1, nombre: "Bootcamp de AWS", desc: "Aprende Arquitectura Cloud Serverless", estado: "Programado" },
    { id: 2, nombre: "Next.js + Tailwind", desc: "Creación de interfaces modernas", estado: "Disponible" }
  ]);

  const crearTallerPrueba = () => {
    console.log("¡En el siguiente sprint conectaremos este botón con tu Cognito para enviar el JWT a tu Lambda!");
  };

  return (
    <main className="min-h-screen bg-gray-50 p-8 font-sans">
      <div className="max-w-4xl mx-auto">
        <header className="flex justify-between items-center mb-10">
          <div>
            <h1 className="text-3xl font-extrabold text-gray-900">Plataforma de Talleres</h1>
            <p className="text-gray-500 mt-1">Gestión y administración de eventos formativos</p>
          </div>
          <button 
            onClick={crearTallerPrueba}
            className="bg-black text-white px-5 py-2.5 rounded-lg shadow hover:bg-gray-800 transition font-medium"
          >
            + Nuevo Taller
          </button>
        </header>
        
        <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
          <h2 className="text-xl font-bold text-gray-800 mb-6">Talleres Activos</h2>
          
          <div className="grid gap-4">
            {talleres.map((taller) => (
              <div key={taller.id} className="p-5 border border-gray-100 rounded-lg bg-gray-50 hover:bg-gray-100 transition flex justify-between items-center">
                <div>
                  <h3 className="font-bold text-lg text-blue-700">{taller.nombre}</h3>
                  <p className="text-sm text-gray-600 mt-1">{taller.desc}</p>
                </div>
                <div className="text-xs font-bold uppercase tracking-wider bg-green-100 text-green-800 px-3 py-1 rounded-full">
                  {taller.estado}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </main>
  );
}