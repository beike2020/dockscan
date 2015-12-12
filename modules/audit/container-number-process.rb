class ContainerNumberProcess < AuditModule

	def info
		return 'This plugin checks number of container processes'
	end

	def check(dockercheck)
		sp=ScanPlugin.new
		si=ScanIssue.new 
		si.title="Container have higher number of processess"
		si.description="Container have more than allowable number of processes.\nThis is not recommended for production as it does not provide intended isolation."
		si.solution="It is recommended to have single process inside container. If you have more than one process, it is recommended to split them in separate containers."
		si.severity=4 # Low
		si.risk = { "cvss" => 3.2 } 
		sp.vuln=si	
		sp.output=""
		if scandata.key?("GetContainersRunning") and not scandata["GetContainersRunning"].obj.empty?
			sp.state="run"
			scandata["GetContainersRunning"].obj.each do |container|
				ps=container.top
				if ps.count > 1 then
					sp.state="vulnerable"
					sp.output << "More than 1 process in #{container.id}: #{ps.count}\n"
					ps.each do |process|
						sp.output << process["CMD"] << "\n"
					end
					sp.output << "\n"
				end
			end
		end
		return sp
	end
end

