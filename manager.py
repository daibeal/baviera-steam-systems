import pandas as pd
from datetime import timedelta

file_path = 'data.csv'

try: 
      # Leer fichero
      data = pd.read_csv(file_path, parse_dates=['end_date'], dayfirst=True, delimiter=",")
      
except:
      print(f"Error al abrir el archivo {file_path}")
      file_path = input('Ingresa la ruta del archivo .csv: ')

# Calcular campos y asignar nombres
data['start_date'] = data['end_date'] - timedelta(days=7)
assignee_names = data['assigned'].unique()
name_to_id = {name: i for i, name in enumerate(assignee_names, 1)}
data['assigned'] = data['assigned'].replace(name_to_id)

# Reordenar y ajustar fecha a formato %d-%m-$y
data = data[['name', 'start_date', 'end_date', 'assigned']]
data[['start_date', 'end_date']] = data[['start_date', 'end_date']].apply(lambda x: x.dt.strftime('%d-%m-%Y'))
# Exportar csv
data.to_csv('projects.csv', index=False)

# Anexar listado de responsables
responsables = pd.DataFrame({'Id': list(name_to_id.values()), 'assigned': list(name_to_id.keys())})
with open('projects.csv', 'a') as f:
    f.write('\n')
responsables.to_csv('projects.csv', mode='a', index=False)