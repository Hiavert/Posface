<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class RunCustomQuery extends Command
{
    protected $signature = 'run:custom-query';
    protected $description = 'Ejecuta el query SQL gigante desde un archivo';

    public function handle()
    {
        $sql = file_get_contents(database_path('scripts/custom_query.sql'));

        DB::unprepared($sql);

        $this->info('Query ejecutado correctamente!');
    }
}
