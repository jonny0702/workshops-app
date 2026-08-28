 'use client';
import { useState, useEffect } from 'react';
import { Amplify } from 'aws-amplify';
import { fetchAuthSession } from 'aws-amplify/auth';
import { Authenticator } from '@aws-amplify/ui-react';
import '@aws-amplify/ui-react/styles.css';

Amplify.configure({
  Auth: {
    Cognito: {
      userPoolId: process.env.NEXT_PUBLIC_COGNITO_USER_POOL_ID as string,
      userPoolClientId: process.env.NEXT_PUBLIC_COGNITO_CLIENT_ID as string,
    }
  }
});

export default function WorkshopsPage() {
  const [talleres, setTalleres] = useState<any[]>([]);
  const [nuevoNombre, setNuevoNombre] = useState('');
  const [nuevaDesc, setNuevaDesc] = useState('');
  const [cargando, setCargando] = useState(false);

  // 1. Cargar datos de DynamoDB al abrir la página
  const cargarTalleres = async () => {
    try {
      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/workshops`);
      const data = await res.json();
      if (res.ok) {
        setTalleres(data);
      }
    } catch (err) {
      console.error("Error cargando talleres:", err);
    }
  };

  useEffect(() => {
    cargarTalleres();
  }, []);

  // 2. Enviar datos a DynamoDB
  const crearTaller = async () => {
    if (!nuevoNombre) return alert("El taller necesita un nombre");
    setCargando(true);
    
    try {
      const { tokens } = await fetchAuthSession();
      const jwt = tokens?.idToken?.toString();

      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/workshops`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': jwt || '' 
        },
        body: JSON.stringify({ nombre: nuevoNombre, desc: nuevaDesc })
      });

      if (res.ok) {
        setNuevoNombre('');
        setNuevaDesc('');
        cargarTalleres(); // Refresca la lista automáticamente
      }
    } catch (err) {
      console.error(err);
      alert("Error al comunicarse con el backend.");
    }
    setCargando(false);
  };

  return (
    <Authenticator loginMechanisms={['email']}>
      {({ signOut, user }) => (
        <main className="min-h-screen bg-gray-50 p-8 font-sans">
          <div className="max-w-4xl mx-auto">
            <header className="flex justify-between items-center mb-10">
              <div>
                <h1 className="text-3xl font-extrabold text-gray-900">Plataforma de Talleres</h1>
                <p className="text-gray-500 mt-1">Usuario: {user?.signInDetails?.loginId}</p>
              </div>
              <button onClick={signOut} className="bg-red-100 text-red-700 px-5 py-2.5 rounded-lg shadow hover:bg-red-200 transition font-medium">
                Salir
              </button>
            </header>
            
            {/* Formulario de Creación */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6 mb-8 flex flex-col md:flex-row gap-4">
              <input 
                type="text" placeholder="Nombre del Taller..." 
                value={nuevoNombre} onChange={e => setNuevoNombre(e.target.value)}
                className="flex-1 border border-gray-300 rounded-lg p-3 outline-none focus:border-black"
              />
              <input 
                type="text" placeholder="Descripción breve..." 
                value={nuevaDesc} onChange={e => setNuevaDesc(e.target.value)}
                className="flex-1 border border-gray-300 rounded-lg p-3 outline-none focus:border-black"
              />
              <button 
                onClick={crearTaller} disabled={cargando}
                className="bg-black text-white px-8 py-3 rounded-lg shadow hover:bg-gray-800 transition font-medium whitespace-nowrap disabled:opacity-50"
              >
                {cargando ? 'Guardando...' : '+ Crear Taller'}
              </button>
            </div>

            {/* Lista Dinámica desde DynamoDB */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-200 p-6">
              <h2 className="text-xl font-bold text-gray-800 mb-6">Talleres Activos ({talleres.length})</h2>
              
              {talleres.length === 0 ? (
                <p className="text-gray-500 text-center py-8">No hay talleres todavía. ¡Crea el primero!</p>
              ) : (
                <div className="grid gap-4">
                  {talleres.map((taller) => (
                    <div key={taller.id} className="p-5 border border-gray-100 rounded-lg bg-gray-50 flex justify-between items-center">
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
              )}
            </div>
          </div>
        </main>
      )}
    </Authenticator>
  );
}