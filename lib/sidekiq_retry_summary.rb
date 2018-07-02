# frozen_string_literal: true

module Sidekiq
  class WebApplication
    get '/retry_summary' do
      @retry_groups = Sidekiq::RetrySet.new.inject(Hash.new(0)) do |hash,job|
        general_error_message =
          job['error_message'].gsub(/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/,'<ID>').
          gsub(/\d+/, '<ID>')

        hash[[job['class'], general_error_message]] += 1

        hash
      end.to_a.sort_by(&:last).reverse.map do |retry_group|
        OpenStruct.new(
          job_name: retry_group[0][0],
          error_message: retry_group[0][1],
          count: retry_group[1]
        )
      end

      template = <<-TEMPLATE
<header class="row">
  <div class="col-sm-5">
    <h3><%= t('Retry Summary') %></h3>
  </div>
</header>

<form action="<%= root_path %>retries" method="post">
  <%= csrf_tag %>
  <div class="table_container">
    <table class="table table-striped table-bordered table-white">
      <thead>
        <tr>
          <th>Count Rank</th>
          <th><%= t('Job') %></th>
          <th><%= t('Error') %></th>
          <th><%= t('Count') %></th>
          <% if defined?(Sidekiq::Pro) %>
            <th><%= t('View') %></th>
            <th><%= t('Jira Ticket') %></th>
          <% end %>
        </tr>
      </thead>
      <% @retry_groups.each_with_index do |group, i| %>
        <tr>
          <td><%= i + 1 %></td>
          <td><%= group.job_name %></td>
          <td>
            <div><%= h message=truncate(group.error_message, 200) %></div>
          </td>
          <td><%= group.count %></td>
          <% if defined?(Sidekiq::Pro) %>
            <td>
              <%view_url = "\#{root_path}filter/retries?substr=\#{CGI.escape(group.error_message.split(/<ID>|"|'|,|:/).sort_by(&:length).last)}" %>
              <a href= "<%=view_url%>" target='_blank'>View</a>
            </td>
          <% end %>
          <td>
            <a href="https://jira.groupondev.com/secure/CreateIssueDetails!init.jspa?pid=17949&issuetype=1&summary=Failed Jobs(<%=group.count%>): <%=CGI.escape message%>&description=<%=CGI.escape "https://cloadmin.groupondev.com\#{view_url}" %>&customfield_12000=key:CLO-3991&priority=4" target='_blank'>Create</a>
          </td>
        </tr>
      <% end %>
    </table>
  </div>
</form>
      TEMPLATE

      render(:erb, template)
    end
  end
end

module Sidekiq
  class Web
    DEFAULT_TABS = {
      "Dashboard" => '',
      "Busy"      => 'busy',
      "Queues"    => 'queues',
      "Retries"   => 'retries',
      "Retry Summary"   => 'retry_summary',
      "Scheduled" => 'scheduled',
      "Dead"      => 'morgue'
    }
  end
end

module Sidekiq
  class WebApplication
    if defined?(Sidekiq::Pro)
      get '/filter/retries' do
        x = params[:substr]
        return redirect "#{root_path}retries" unless x && x != ''

        @retries = search(Sidekiq::RetrySet.new, params[:substr])[0..100]

        erb :retries
      end
    end
  end
end
