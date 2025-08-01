<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class RunCustomQuery extends Command
{
    // Nombre del comando en consola
    protected $signature = 'run:custom-query';

    // Descripción del comando
    protected $description = 'Ejecuta un query gigante desde un archivo SQL';

    public function handle()
    {
        $path = database_path('scripts/posface.sql');

        if (!file_exists($path)) {
            $this->error("No se encontró el archivo SQL en: $path");
            return 1; // Error
        }

        $sql = file_get_contents($path);

        try {
            DB::unprepared($sql);
            $this->info('Query gigante ejecutado con éxito.');
            return 0; // Éxito
        } catch (\Exception $e) {
            $this->error('Error al ejecutar el query: ' . $e->getMessage());
            return 1; // Error
        }
    }
}
