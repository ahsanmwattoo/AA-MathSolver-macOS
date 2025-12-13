//
//  AIAssistants.swift
//  Brainify-AI-Mac
//
//  Created by Hasna Fiaz on 28/11/2025.
//
import Cocoa

struct AIAssistants {
    let title: String
    let subtitle: String
    let icon: NSImage
    let placeholder: String
    
    static var all: [AIAssistants] = [
        AIAssistants(title: "Write a Story", subtitle: "Craft an engaging narrative with creativity and structure.", icon: .writeAStoryIcon, placeholder: "Enter your story idea here."),
        AIAssistants(title: "Write an Email", subtitle: "Compose a professional or personal email.", icon: .writeAnEmailIcon, placeholder: "Enter your email text here."),
        AIAssistants(title: "Summarize Content", subtitle: "Condense lengthy content into a concise overview.", icon: .summarizeContentIcon, placeholder: "Paste your content here to summarize it."),
        AIAssistants(title: "Translate a Text", subtitle: "Convert text from one language to another with accuracy.", icon: .translateATextIcon, placeholder: "Enter the text you want to translate here."),
        AIAssistants(title: "Create a Blog Post", subtitle: "Develop an informative and engaging blog article.", icon: .createABlogPostIcon, placeholder: "Enter your blog content here."),
        AIAssistants(title: "Write an Essay", subtitle: "Write a well-structured essay on any topic.", icon: .writeAnEssayIcon, placeholder: "Enter your essay topic here."),
        AIAssistants(title: "Compose a Poem", subtitle: "Craft a creative poem with rhythm, rhyme, and emotion.", icon: .composeAPoemIcon, placeholder: "Enter your poem’s theme or first lines here."),
        AIAssistants(title: "Draft a Report", subtitle: "Write a formal report with findings and recommendations.", icon: .draftAReportIcon, placeholder: "Enter your report content here."),
        AIAssistants(title: "Write a Letter", subtitle: "Draft a formal or personal letter.", icon: .writeALetterIcon, placeholder: "Enter your letter recipient and message here."),
        AIAssistants(title: "Create a Speech", subtitle: "Develop an inspiring and persuasive speech.", icon: .createASpeechIcon, placeholder: "Enter your speech content here."),
        AIAssistants(title: "Product Description", subtitle: "Write a compelling description for a product.", icon: .productDescriptionIcon, placeholder: "Enter product details here."),
        AIAssistants(title: "Write a Review", subtitle: "Share your opinion and experience with a product, service, or experience.", icon: .writeAReviewIcon, placeholder: "Enter your review here."),
        AIAssistants(title: "Develop a Script", subtitle: "Create a screenplay or dialogue for a film or play.", icon: .developAScriptIcon, placeholder: "Enter your scene or character dialogue here."),
        AIAssistants(title: "Social Media Caption", subtitle: "Write a catchy and engaging caption for social media posts.", icon: .socialMediaCaptionIcon, placeholder: "Enter your caption here."),
        AIAssistants(title: "Write a Resume", subtitle: "Craft a professional and detailed resume for a job application.", icon: .writeAResumeIcon, placeholder: "Enter your personal details here."),
        AIAssistants(title: "Press Release", subtitle: "Write a formal announcement to share news or information.", icon: .pressReleaseIcon, placeholder: "Enter your release here.")
        ]
}

