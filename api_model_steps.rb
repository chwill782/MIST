And(/^the following "([^"]+)" exist through the Api Utility Service:$/) do |plural, table|
  table.hashes.each { |row| send("create_#{plural .singularize .parameterize('_')}", row)}
end

And(/^I update the following "([^"]+)" through the Api Utility Service:$/) do |plural, table|
  send("update_#{plural .singularize .parameterize('_')}", table)
end

And(/^I delete all scenarios from the study:? ([^"]+)$/) do |study|
  $client_division.study(study).clean_all
end

And /^I assign ([^"]+) to the following ([^"]+) in ([^"]+) through the Api Utility Service:$/ do |what_to, to_what,schedule, table|
  schedule = $sticky[schedule.to_sym] if $sticky.has_key? schedule.to_sym
  case what_to
    when /^(?:visit)?\s*optional conditional$/i
      update_optional_conditional(to_what, schedule, table)
    else
      raise StandardError, "No implementation found for #{what_to}."
  end
end

And /^I assign Purpose for study cell with activity "([^"]+)" and visit "([^"]+)" through the Api Utility Service:$/ do |activity, event, table|
  update_purpose(activity, event, table)
end


def create_client_division(opt = {})
  $client_division = APIs::ClientDivision.new(opt['app'], opt['user'], opt['client division'])
  $activities = APIs::Activities.new(opt['app'], opt['user'])

  $study_statistics = APIs::StudyStatistics.new(opt['app'], opt['user'])
  $activity_benchmark = APIs::ActivityBenchmark.new(opt['app'], opt['user'])

  $api_user = opt['user']
  $api_application = opt['app']
end

def create_study(opt = {})
  $client_division.add_study(opt['study'])
end

def create_design_scenario(opt = {})
  $client_division.study(opt['study']).add_design_scenario(opt.keys.select { |header| ['name', 'description', 'note'].include? header }.collect { |val| {val.to_sym => opt[val]} }.inject(&:merge))
  $sticky[opt['stored as'].to_sym] = opt['name'] if opt.has_key? 'stored as'
end

def create_objective(opt = {})
  scenario = ($sticky.has_key? opt['design scenario'].to_sym) ? $sticky[opt['design scenario'].to_sym] : opt['design scenario']
  $client_division.study.design_scenario(scenario).add_objective(opt.keys.select { |header| ['objective_type', 'description'].include? header }.collect { |val| {val.to_sym => opt[val]} }.inject(&:merge))
end

def create_endpoint(opt = {})
  scenario = ($sticky.has_key? opt['design scenario'].to_sym) ? $sticky[opt['design scenario'].to_sym] : opt['design scenario']
  headers = ['objective_type','objective_description', 'endpoint_type', 'endpoint_subtype', 'description']
  $client_division.study.design_scenario(scenario).objective(opt.keys.select { |header| ['objective_type', 'objective_description'].include? header }.collect { |val| {val.to_sym => opt[val]} }.inject(&:merge))
      .add_endpoint(opt.keys.select { |header| headers.include? header }.collect { |val| {val.to_sym => opt[val]} }.inject(&:merge))
end

def create_scenario_schedule(opt = {})
  scenario = ($sticky.has_key? opt['design scenario'].to_sym) ? $sticky[opt['design scenario'].to_sym] : opt['design scenario']
  $client_division.study.design_scenario(scenario).add_scenario_schedule(opt['schedule name'])
  $sticky[opt['stored as'].to_sym] = opt['schedule name'] if opt.has_key? 'stored as'
end

def create_activity(opt = {})
  scenario = ($sticky.has_key? opt['design scenario'].to_sym) ? $sticky[opt['design scenario'].to_sym] : opt['design scenario']
  schedule = ($sticky.has_key? opt['schedule'].to_sym) ? $sticky[opt['schedule'].to_sym] : opt['schedule']
  activity = opt.dup.delete('activity')

  $client_division.study.design_scenario(scenario).scenario_schedule(schedule).
      add_study_activity($activities.collect(activity))
end

def create_study_event(opt = {})
  scenario = ($sticky.has_key? opt['design scenario'].to_sym) ? $sticky[opt['design scenario'].to_sym] : opt['design scenario']
  schedule = ($sticky.has_key? opt['schedule'].to_sym) ? $sticky[opt['schedule'].to_sym] : opt['schedule']

  $client_division.study.design_scenario(scenario).scenario_schedule(schedule).
      add_study_event(name: opt['event'],
                      encounter_type: opt['encounter type'],
                      visit_type: opt['visit type'])
end

def create_study_cell(opt = {})
  scenario = ($sticky.has_key? opt['design scenario'].to_sym) ? $sticky[opt['design scenario'].to_sym] : opt['design scenario']
  schedule = ($sticky.has_key? opt['schedule'].to_sym) ? $sticky[opt['schedule'].to_sym] : opt['schedule']

  $client_division.study.design_scenario(scenario).scenario_schedule(schedule).
      add_study_cells([ {activity: opt['activity'], event: opt['event']} ])

  sleep 0.01
end

def update_optional_conditional(to_what, schedule, table)
  value = lambda { |i| i.match(/^\d+\.?\d*$/) ? i.to_f : activity_visit_optional_conditional_ref_id(i) }
  options = [
      'optional conditional type',
      'optional quantity',
      'percentage of subjects',
      'required minimum quantity'
  ]
  events = ['activity', 'event']

  data = table.hashes.collect do |row|
    headers_as_opt_cond_ref_ids =
        row.keys.
            select  { |header| options.include?(header) }.
            collect { |opt| {opt.downcase.gsub(/\s/, '_') => value.call(row[opt])} }.
            reduce(&:merge)
    header_values =
        row.keys.
            select  { |header| events.include?(header) }.
            collect { |opt| {opt.to_sym => row[opt]} }.
            reduce(&:merge)

    { attrs: headers_as_opt_cond_ref_ids }.merge!(header_values)
  end

  case to_what
    when /^study cells$/i
      $client_division.study.design_scenario.scenario_schedule(schedule).update_cell(data)
    when /^study events?$/i
      $client_division.study.design_scenario.scenario_schedule(schedule).update_study_events(data)
  end

  sleep 5
end

def update_purpose(activity, event, table)
  study_cells = (activity && event) ? [{activity: activity, event: event}] : nil
  purposes = table.hashes.collect do |row|
    params = {}
    table.column_names.each { |col| params[col.sub(/ /, '_').to_sym] = row[col] }
    params
  end
  $client_division.study.design_scenario.add_purposes(study_cells, purposes)
end

def update_reference(table)
  begin
    file = lambda { |f| File.join('features', 'step_definitions', 'apis', f) }
    data_hash = lambda { |file, value| value ||= JSON.parse(File.read(file)) if File.exist? file }
  end
  indication_data = data_hash.call(file.call('indication_data.json'), indication_data)
  phase_data = data_hash.call(file.call('phase_data.json'), phase_data)
  de_references = ['primary indication', 'secondary indication', 'phase']
  redirect =
      {
          'primary indication' => ['primary_indication_uuid', indication_data],
          'secondary indication' => ['secondary_indication_uuid', indication_data],
          'phase' => ['phase_uuid', phase_data]
      }
  content = table.rows_hash.select { |key, value| de_references.include? key }.map { |k, v| {redirect[k][0] => redirect[k][1][v]} }.inject(&:merge)

  references = ['name', 'protocol_id', 'primary indication_uuid', 'secondary indication_uuid', 'phase_uuid', 'test_study']
  $client_division.update_study_references(table.rows_hash.select { |key, value| references.include? key }.merge! content)
end

def activity_visit_optional_conditional_ref_id(type)
  case type
    when /^perform for all subjects$/i
      {name:'aoc_item_type.perform_for_all_subjects', id: 1}
    when /^specified subject gender$/i
      {name:'aoc_item_type.specified_subject_gender', id: 2}
    when /^specified medical history(?: \/)? condition$/i
      {name:'aoc_item_type.specified_medical_history_condition', id: 3}
    when /^procedure not previously performed within specified time period$/i
      {name:'aoc_item_type.procedure_not_previously_performed_within_specified_time_period', id: 4}
    when /^conditional on procedure result(?: \/)? symptom$/i
      {name:'aoc_item_type.conditional_on_procedure_result_symptom', id: 5}
    when /^(?:as )?clinically warranted$/i
      {name:'aoc_item_type.clinically_warranted', id: 6}
    when /^optional for subject$/i
      {name:'aoc_item_type.optional_for_subject', id: 7}
    when /^until valid reading recorded$/i
      {name:'aoc_item_type.until_valid_reading_recorded', id: 8}
    when /^optional or conditional(?: -)? other$/i
      {name:'aoc_item_type.optional_or_conditional_other', id: 9}
    when /^(?:scheduled -?\s*)?for all subjects$/i
      {name:'study_event_optional_conditional_type.scheduled_for_all_subjects', id: 1}
    when /^(?:scheduled -?\s*)?conditional on procedure result$/i
      {name: 'study_event_optional_conditional_type.scheduled_conditional_on_proc_result', id: 2}
    when /^(?:scheduled -?\s*)?optional for subject$/i
      {name: 'study_event_optional_conditional_type.scheduled_optional_for_subject', id: 3}
    when /^(?:unscheduled -?\s*)?early withdrawal$/i
      {name: 'study_event_optional_conditional_type.unscheduled_early_withdrawal', id: 4}
    when /^(?:unscheduled -?\s*)?in case of adverse event$/i
      {name: 'study_event_optional_conditional_type.unscheduled_in_adverse_event', id: 5}
    when /^(?:unscheduled -?\s*)?other$/i
      {name: 'study_event_optional_conditional_type.unscheduled_other', id: 6}
    else
      type
  end
end
