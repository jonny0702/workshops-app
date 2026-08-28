'use client';
import { useState } from 'react';
import { Amplify } from 'aws-amplify';
import { fetchAuthSession } from 'aws-amplify/auth';
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';

// 1. Conectamos Next.js con tu Cognito de Terraform
Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: process.env.NEXT_PUBLIC_COGNITO_USER_POOL_ID as string,
      userPoolClientId: process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID as string,
    }
  }
});

export default function WorkshopsPage() {
  const [talleres, setTalleres] = useState([
    { id: 1, nombre: "Bootcamp de AWS", desc: "Aprende Arquitectura Cloud Serverless", estado: "Programado" }
  ]);

  // 2. Función que dispara el evento a la Lambda
  const crearTallerPrueba = async () => {
    try {
      // Extraemos el Token JWT de la sesión activa
      const { tokens } = await fetchAuthSession();
      const jwt = tokens?.idToken?.toString();

      // Hacemos el POST a tu API Gateway (protegido)
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/workshops`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwt || '' // Enviamos el Token al "Guardaespaldas"
        },
        body: JSON.stringify({ nombre: "Masterclass de Terraform" })
      });

      const data = await res.json();
      
      if (res.ok) {
        alert("¡Éxito! " + data.mensaje);
        // Si tienes tu terminal abierta, verás que te llega el correo de SNS.
      } else {
        alert("Error de API: " + JSON.stringify(data));
      }
    } catch (err) {
      console.error(err);
      alert("Error al comunicarse con el backend.");
    }
  };

  return (
    <Authenticator>
      {({ signOut, user }) => (
        <main className="min-h-screen bg-gray-50 p-8 font-sans">
          <div className="max-w-4xl mx-auto">
            <header className="flex justify-between items-center mb-10">
              <div>
                <h1 className="text-3xl font-extrabold text-gray-900">Plataforma de Talleres</h1>
                <p className="text-gray-500 mt-1">Bienvenido, {user?.signInDetails?.loginId}</p>
              </div>
              <div className="flex gap-4">
                <button 
                  onClick={crearTallerPrueba}
                  className="bg-black text-white px-5 py-2.5 rounded-lg shadow hover:bg-gray-800 transition font-medium"
                >
                  + Nuevo Taller
                </button>
                <button 
                  onClick={signOut}
                  className="bg-red-100 text-red-700 px-5 py-2.5 rounded-lg shadow hover:bg-red-200 transition font-medium"
                >
                  Salir
                </button>
              </div>
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
      )}
    </Authenticator>
  );
}